﻿/*
===========================================================================

Copyright (c) 2010-2015 Darkstar Dev Teams

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/

===========================================================================
*/

#include "mob_controller.h"
#include "../../../common/utils.h"
#include "../../enmity_container.h"
#include "../../entities/mobentity.h"
#include "../../mob_modifier.h"
#include "../../mob_spell_container.h"
#include "../../mobskill.h"
#include "../../party.h"
#include "../../status_effect_container.h"
#include "../../utils/battleutils.h"
#include "../../utils/petutils.h"
#include "../ai_container.h"
#include "../helpers/targetfind.h"
#include "../states/ability_state.h"
#include "../states/magic_state.h"
#include "../states/weaponskill_state.h"

CMobController::CMobController(CMobEntity* PEntity)
: CController(PEntity)
, PMob(PEntity)
{
}

void CMobController::Tick(time_point tick)
{
    TracyZoneScoped;
    TracyZoneIString(PMob->GetName());

    m_Tick = tick;

    if (PMob->isAlive())
    {
        if (PMob->PAI->IsEngaged())
        {
            DoCombatTick(tick);
        }
        else if (!PMob->isDead())
        {
            DoRoamTick(tick);
        }
    }
}

bool CMobController::TryDeaggro()
{
    TracyZoneScoped;
    if (PTarget == nullptr && (PMob->PEnmityContainer != nullptr && PMob->PEnmityContainer->GetHighestEnmity() == nullptr))
    {
        return true;
    }

    // target is no longer valid, so wipe them from our enmity list
    if (!PTarget || PTarget->isDead() || PTarget->isMounted() || PTarget->loc.zone->GetID() != PMob->loc.zone->GetID() ||
        PMob->StatusEffectContainer->GetConfrontationEffect() != PTarget->StatusEffectContainer->GetConfrontationEffect() ||
        PMob->allegiance == PTarget->allegiance || CheckDetection(PTarget) || CheckHide(PTarget) || CheckLock(PTarget))
    {
        if (PTarget)
        {
            PMob->PEnmityContainer->Clear(PTarget->id);
        }
        PTarget = PMob->PEnmityContainer->GetHighestEnmity();
        PMob->SetBattleTargetID(PTarget ? PTarget->targid : 0);
        return TryDeaggro();
    }

    return false;
}

bool CMobController::CanPursueTarget(CBattleEntity* PTarget)
{
    TracyZoneScoped;
    if (PMob->m_Detects & DETECT_SCENT)
    {
        // if mob is in water it will instant deaggro if target cannot be detected
        if (!PMob->PAI->PathFind->InWater() && !PTarget->StatusEffectContainer->HasStatusEffect(EFFECT_DEODORIZE))
        {
            // certain weather / deodorize will turn on time deaggro
            return PMob->m_disableScent;
        }
    }
    return false;
}

bool CMobController::CheckHide(CBattleEntity* PTarget)
{
    TracyZoneScoped;
    if (PTarget->GetMJob() == JOB_THF && PTarget->StatusEffectContainer->HasStatusEffect(EFFECT_HIDE))
    {
        return !CanPursueTarget(PTarget) && !PMob->m_TrueDetection;
    }
    return false;
}

bool CMobController::CheckLock(CBattleEntity* PTarget)
{
    TracyZoneScoped;
    if (PTarget->objtype == TYPE_PC)
    {
        CCharEntity* PChar = dynamic_cast<CCharEntity*>(PTarget);
        if (PChar->m_Locked)
        {
            return !CanPursueTarget(PTarget);
        }
    }
    else if (PTarget->objtype == TYPE_PET)
    {
        CPetEntity*  PPet  = dynamic_cast<CPetEntity*>(PTarget);
        CCharEntity* PChar = dynamic_cast<CCharEntity*>(PPet->PMaster);

        if (PChar == nullptr)
        {
            return false;
        }

        if (PChar->m_Locked)
        {
            return !CanPursueTarget(PTarget);
        }
    }
    return false;
}

bool CMobController::CheckDetection(CBattleEntity* PTarget)
{
    TracyZoneScoped;
    if (CanDetectTarget(PTarget) || CanPursueTarget(PTarget) ||
        PMob->StatusEffectContainer->HasStatusEffect({ EFFECT_BIND, EFFECT_SLEEP, EFFECT_SLEEP_II, EFFECT_LULLABY, EFFECT_PETRIFICATION }))
    {
        TapDeaggroTime();
    }

    return PMob->CanDeaggro() && (m_Tick >= m_DeaggroTime + 25s);
}

void CMobController::TryLink()
{
    TracyZoneScoped;
    if (PTarget == nullptr)
    {
        return;
    }

    // handle pet behaviour on the targets behalf (faster than in ai_pet_dummy)
    // Avatars defend masters by attacking mobs if the avatar isn't attacking anything currently (bodyguard behaviour)
    if (PTarget->PPet != nullptr && PTarget->PPet->GetBattleTargetID() == 0)
    {
        if (PTarget->PPet->objtype == TYPE_PET && ((CPetEntity*)PTarget->PPet)->getPetType() == PET_TYPE::AVATAR)
        {
            petutils::AttackTarget(PTarget, PMob);
        }
    }

    // my pet should help as well
    if (PMob->PPet != nullptr && PMob->PPet->PAI->IsRoaming())
    {
        ((CMobEntity*)PMob->PPet)->PEnmityContainer->AddBaseEnmity(PTarget);
    }

    // Handle monster linking if they are close enough
    if (PMob->PParty != nullptr)
    {
        for (auto& member : PMob->PParty->members)
        {
            CMobEntity* PPartyMember = dynamic_cast<CMobEntity*>(member);
            if (!PPartyMember)
            {
                continue;
            }

            if (PPartyMember->PAI->IsRoaming() && PPartyMember->CanLink(&PMob->loc.p, PMob->getMobMod(MOBMOD_SUPERLINK)))
            {
                PPartyMember->PEnmityContainer->AddBaseEnmity(PTarget);

                if (PPartyMember->m_roamFlags & ROAMFLAG_IGNORE)
                {
                    // force into attack action
                    //#TODO
                    PPartyMember->PAI->Engage(PTarget->targid);
                }
            }
        }
    }

    // ask my master for help
    if (PMob->PMaster != nullptr && PMob->PMaster->PAI->IsRoaming())
    {
        CMobEntity* PMaster = (CMobEntity*)PMob->PMaster;

        if (PMaster->PAI->IsRoaming() && PMaster->CanLink(&PMob->loc.p, PMob->getMobMod(MOBMOD_SUPERLINK)))
        {
            PMaster->PEnmityContainer->AddBaseEnmity(PTarget);
        }
    }
}

/**
 * Checks if the mob can detect the target using it's detection (sight, sound, etc)
 * This is used to aggro and deaggro (Mobs start to deaggro after failing to detect target).
 **/
bool CMobController::CanDetectTarget(CBattleEntity* PTarget, bool forceSight)
{
    TracyZoneScoped;
    if (PTarget->isDead() || PTarget->isMounted())
    {
        return false;
    }

    auto detects         = PMob->m_Detects;
    auto currentDistance = distance(PTarget->loc.p, PMob->loc.p) + PTarget->getMod(Mod::STEALTH);

    bool detectSight  = (detects & DETECT_SIGHT) || forceSight;
    bool hasInvisible = false;
    bool hasSneak     = false;

    if (!PMob->m_TrueDetection)
    {
        hasInvisible = PTarget->StatusEffectContainer->HasStatusEffectByFlag(EFFECTFLAG_INVISIBLE);
        hasSneak     = PTarget->StatusEffectContainer->HasStatusEffect(EFFECT_SNEAK);
    }

    if (detectSight && !hasInvisible && currentDistance < PMob->getMobMod(MOBMOD_SIGHT_RANGE) && facing(PMob->loc.p, PTarget->loc.p, 64))
    {
        return CanSeePoint(PTarget->loc.p);
    }

    if ((PMob->m_Behaviour & BEHAVIOUR_AGGRO_AMBUSH) && currentDistance < 3 && !hasSneak)
    {
        return true;
    }

    if ((detects & DETECT_HEARING) && currentDistance < PMob->getMobMod(MOBMOD_SOUND_RANGE) && !hasSneak)
    {
        return CanSeePoint(PTarget->loc.p);
    }

    // everything below require distance to be below 20
    if (currentDistance > 20)
    {
        return false;
    }

    if ((detects & DETECT_LOWHP) && PTarget->GetHPP() < 75)
    {
        return CanSeePoint(PTarget->loc.p);
    }

    if ((detects & DETECT_MAGIC) && PTarget->PAI->IsCurrentState<CMagicState>() &&
        static_cast<CMagicState*>(PTarget->PAI->GetCurrentState())->GetSpell()->hasMPCost())
    {
        return CanSeePoint(PTarget->loc.p);
    }

    if ((detects & DETECT_WEAPONSKILL) && PTarget->PAI->IsCurrentState<CWeaponSkillState>())
    {
        return CanSeePoint(PTarget->loc.p);
    }

    if ((detects & DETECT_JOBABILITY) && PTarget->PAI->IsCurrentState<CAbilityState>())
    {
        return CanSeePoint(PTarget->loc.p);
    }

    return false;
}

bool CMobController::CanSeePoint(position_t pos)
{
    TracyZoneScoped;
    if (PMob->PAI->PathFind)
    {
        return PMob->PAI->PathFind->CanSeePoint(pos);
    }

    return true;
}

bool CMobController::MobSkill(int wsList)
{
    TracyZoneScoped;
    /* #TODO: mob 2 hours, etc */
    if (!wsList)
    {
        wsList = PMob->getMobMod(MOBMOD_SKILL_LIST);
    }

    auto skillList{ battleutils::GetMobSkillList(wsList) };

    if (auto overrideSkill = luautils::OnMobWeaponSkillPrepare(PMob, PTarget); overrideSkill > 0)
    {
        skillList = { overrideSkill };
    }

    if (skillList.empty())
    {
        return false;
    }

    std::shuffle(skillList.begin(), skillList.end(), xirand::mt());
    CBattleEntity* PActionTarget{ nullptr };

    for (auto skillid : skillList)
    {
        auto* PMobSkill{ battleutils::GetMobSkill(skillid) };
        if (!PMobSkill)
        {
            continue;
        }

        if (PMobSkill->getValidTargets() == TARGET_ENEMY) // enemy
        {
            PActionTarget = PTarget;
        }
        else if (PMobSkill->getValidTargets() == TARGET_SELF) // self
        {
            PActionTarget = PMob;
        }
        else
        {
            continue;
        }

        PActionTarget = luautils::OnMobSkillTarget(PActionTarget, PMob, PMobSkill);

        if (PActionTarget && !PMobSkill->isAstralFlow() && luautils::OnMobSkillCheck(PActionTarget, PMob, PMobSkill) == 0) // A script says that the move in question is valid
        {
            float currentDistance = distance(PMob->loc.p, PActionTarget->loc.p);

            if (currentDistance <= PMobSkill->getDistance())
            {
                return MobSkill(PActionTarget->targid, PMobSkill->getID());
            }
        }
    }

    return false;
}

bool CMobController::TrySpecialSkill()
{
    TracyZoneScoped;
    // get my special skill
    CMobSkill*     PSpecialSkill  = battleutils::GetMobSkill(PMob->getMobMod(MOBMOD_SPECIAL_SKILL));
    CBattleEntity* PAbilityTarget = nullptr;
    m_LastSpecialTime             = m_Tick;

    if (PSpecialSkill == nullptr)
    {
        ShowError("CAIMobDummy::ActionSpawn Special skill was set but not found! (%d)", PMob->getMobMod(MOBMOD_SPECIAL_SKILL));
        return false;
    }

    if (!IsWeaponSkillEnabled())
    {
        return false;
    }

    if ((PMob->m_specialFlags & SPECIALFLAG_HIDDEN) && !PMob->IsNameHidden())
    {
        return false;
    }

    if (PSpecialSkill->getValidTargets() & TARGET_SELF)
    {
        PAbilityTarget = PMob;
    }
    else if (PTarget != nullptr)
    {
        // distance check for special skill
        float currentDistance = distance(PMob->loc.p, PTarget->loc.p);

        if (currentDistance <= PSpecialSkill->getDistance())
        {
            PAbilityTarget = PTarget;
        }
        else
        {
            return false;
        }
    }
    else
    {
        return false;
    }

    if (luautils::OnMobSkillCheck(PAbilityTarget, PMob, PSpecialSkill) == 0)
    {
        return MobSkill(PAbilityTarget->targid, PSpecialSkill->getID());
    }

    return false;
}

bool CMobController::TryCastSpell()
{
    TracyZoneScoped;
    if (!CanCastSpells())
    {
        return false;
    }

    m_LastMagicTime = m_Tick - std::chrono::milliseconds(xirand::GetRandomNumber(PMob->getBigMobMod(MOBMOD_MAGIC_COOL) / 2));

    // Find random spell from list
    std::optional<SpellID> chosenSpellId;
    if (m_firstSpell)
    {
        // mobs first spell, should be aggro spell
        chosenSpellId = PMob->SpellContainer->GetAggroSpell();
        m_firstSpell  = false;
    }
    else
    {
        chosenSpellId = PMob->SpellContainer->GetSpell();
    }

    // Try to get an override spell from the script (if available)
    auto possibleOverriddenSpell = luautils::OnMobMagicPrepare(PMob, PTarget, chosenSpellId);
    if (possibleOverriddenSpell.has_value())
    {
        chosenSpellId = possibleOverriddenSpell;
    }

    if (chosenSpellId.has_value())
    {
        CastSpell(chosenSpellId.value());
        return true;
    }

    return false;
}

bool CMobController::CanCastSpells()
{
    TracyZoneScoped;
    if (!PMob->SpellContainer->HasSpells())
    {
        return false;
    }

    // check for spell blockers e.g. silence
    if (PMob->StatusEffectContainer->HasStatusEffect({ EFFECT_SILENCE, EFFECT_MUTE }))
    {
        return false;
    }

    // smn can only cast spells if it has no pet
    if (PMob->GetMJob() == JOB_SMN)
    {
        if (PMob->PPet == nullptr || !PMob->PPet->isDead())
        {
            return false;
        }
    }

    return IsMagicCastingEnabled();
}

void CMobController::CastSpell(SpellID spellid)
{
    TracyZoneScoped;
    CSpell* PSpell = spell::GetSpell(spellid);
    if (PSpell == nullptr)
    {
        ShowWarning("ai_mob_dummy::CastSpell: SpellId <%i> is not found", static_cast<uint16>(spellid));
    }
    else
    {
        CBattleEntity* PCastTarget = nullptr;
        // check valid targets
        if (PSpell->getValidTarget() & TARGET_SELF)
        {
            PCastTarget = PMob;

            // only buff other targets if i'm roaming
            if ((PSpell->getValidTarget() & TARGET_PLAYER_PARTY))
            {
                // chance to target my master
                if (PMob->PMaster != nullptr && xirand::GetRandomNumber(2) == 0)
                {
                    // target my master
                    PCastTarget = PMob->PMaster;
                }
                else if (xirand::GetRandomNumber(2) == 0)
                {
                    // chance to target party
                    PMob->PAI->TargetFind->reset();
                    PMob->PAI->TargetFind->findWithinArea(PMob, AOE_RADIUS::ATTACKER, PSpell->getRange());

                    if (!PMob->PAI->TargetFind->m_targets.empty())
                    {
                        // randomly select a target
                        PCastTarget = PMob->PAI->TargetFind->m_targets[xirand::GetRandomNumber(PMob->PAI->TargetFind->m_targets.size())];

                        // only target if are on same action
                        if (PMob->PAI->IsEngaged() == PCastTarget->PAI->IsEngaged())
                        {
                            PCastTarget = PMob;
                        }
                    }
                }
            }
        }
        else
        {
            PCastTarget = PTarget;
        }

        if (PCastTarget)
        {
            Cast(PCastTarget->targid, spellid);
        }
    }
}

void CMobController::DoCombatTick(time_point tick)
{
    TracyZoneScopedC(0xFF0000);
    if (PMob->m_OwnerID.targid != 0 && static_cast<CCharEntity*>(PMob->GetEntity(PMob->m_OwnerID.targid))->PClaimedMob != static_cast<CBattleEntity*>(PMob))
    {
        if (m_Tick >= m_DeclaimTime + 3s)
        {
            PMob->m_OwnerID.clean();
            PMob->updatemask |= UPDATE_STATUS;
        }
    }

    HandleEnmity();
    PTarget = static_cast<CBattleEntity*>(PMob->GetEntity(PMob->GetBattleTargetID()));

    if (TryDeaggro())
    {
        Disengage();
        return;
    }

    TryLink();

    float currentDistance = distance(PMob->loc.p, PTarget->loc.p);

    PMob->PAI->EventHandler.triggerListener("COMBAT_TICK", CLuaBaseEntity(PMob));
    luautils::OnMobFight(PMob, PTarget);

    // Try to spellcast (this is done first so things like Chainspell spam is prioritised over TP moves etc.
    if (IsSpecialSkillReady(currentDistance) && TrySpecialSkill())
    {
        return;
    }
    else if (IsSpellReady(currentDistance) && TryCastSpell())
    {
        return;
    }
    else if (m_Tick >= m_LastMobSkillTime && xirand::GetRandomNumber(1, 10000) <= PMob->TPUseChance() && MobSkill())
    {
        return;
    }

    Move();
}

void CMobController::FaceTarget(uint16 targid)
{
    TracyZoneScoped;
    CBaseEntity* targ = PTarget;
    if (targid != 0 && ((targ && targid != targ->targid) || !targ))
    {
        targ = PMob->GetEntity(targid);
    }
    if (!(PMob->m_Behaviour & BEHAVIOUR_NO_TURN) && targ)
    {
        PMob->PAI->PathFind->LookAt(targ->loc.p);
    }
}

void CMobController::Move()
{
    TracyZoneScoped;
    if (!PMob->PAI->CanFollowPath())
    {
        return;
    }
    if (PMob->PAI->PathFind->IsFollowingScriptedPath() && PMob->PAI->CanFollowPath())
    {
        PMob->PAI->PathFind->FollowPath(m_Tick);
        return;
    }

    // attempt to teleport
    if (PMob->getMobMod(MOBMOD_TELEPORT_TYPE) == 1)
    {
        if (m_Tick >= m_LastSpecialTime + std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_TELEPORT_CD)))
        {
            CMobSkill* teleportBegin = battleutils::GetMobSkill(PMob->getMobMod(MOBMOD_TELEPORT_START));

            if (teleportBegin)
            {
                m_LastSpecialTime = m_Tick;
                MobSkill(PMob->targid, teleportBegin->getID());
            }
        }
    }

    bool  move         = PMob->PAI->PathFind->IsFollowingPath();
    float attack_range = PMob->GetMeleeRange();

    if (PMob->getMobMod(MOBMOD_ATTACK_SKILL_LIST) > 0)
    {
        auto skillList{ battleutils::GetMobSkillList(PMob->getMobMod(MOBMOD_ATTACK_SKILL_LIST)) };

        if (!skillList.empty())
        {
            auto* skill{ battleutils::GetMobSkill(skillList.front()) };
            if (skill)
            {
                attack_range = skill->getDistance();
            }
        }
    }

    float currentDistance = distance(PMob->loc.p, PTarget->loc.p);
    if (PMob->getMobMod(MOBMOD_SHARE_POS) > 0)
    {
        CMobEntity* posShare = (CMobEntity*)PMob->GetEntity(PMob->getMobMod(MOBMOD_SHARE_POS) + PMob->targid, TYPE_MOB);
        PMob->loc            = posShare->loc;
    }
    else if (((currentDistance > attack_range - 0.2f) || move) && PMob->PAI->CanFollowPath())
    {
        //#TODO: can this be moved to scripts entirely?
        if (PMob->getMobMod(MOBMOD_DRAW_IN) > 0)
        {
            if (currentDistance >= PMob->GetMeleeRange() * 2 && battleutils::DrawIn(PTarget, PMob, PMob->GetMeleeRange() - 0.2f))
            {
                FaceTarget();
            }
        }
        if (PMob->speed != 0 && PMob->getMobMod(MOBMOD_NO_MOVE) == 0 && m_Tick >= m_LastSpecialTime)
        {
            // attempt to teleport to target (if in range)
            if (PMob->getMobMod(MOBMOD_TELEPORT_TYPE) == 2)
            {
                CMobSkill* teleportBegin = battleutils::GetMobSkill(PMob->getMobMod(MOBMOD_TELEPORT_START));

                if (teleportBegin && currentDistance <= teleportBegin->getDistance())
                {
                    MobSkill(PMob->targid, teleportBegin->getID());
                    m_LastSpecialTime = m_Tick;
                    return;
                }
            }
            else if (CanMoveForward(currentDistance))
            {
                if (!PMob->PAI->PathFind->IsFollowingPath() || distanceSquared(PMob->PAI->PathFind->GetDestination(), PTarget->loc.p) > 10)
                {
                    // path to the target if we don't have a path already
                    PMob->PAI->PathFind->PathInRange(PTarget->loc.p, attack_range - 0.2f, PATHFLAG_WALLHACK | PATHFLAG_RUN);
                }
                PMob->PAI->PathFind->FollowPath(m_Tick);
                if (!PMob->PAI->PathFind->IsFollowingPath())
                {
                    bool needToMove = false;

                    // arrived at target - move if there is another mob under me
                    if (PTarget->objtype == TYPE_PC)
                    {
                        for (auto PSpawnedMob : static_cast<CCharEntity*>(PTarget)->SpawnMOBList)
                        {
                            if (PSpawnedMob.second != PMob && !PSpawnedMob.second->PAI->PathFind->IsFollowingPath() &&
                                distance(PSpawnedMob.second->loc.p, PMob->loc.p) < 1.f)
                            {
                                auto angle = worldAngle(PMob->loc.p, PTarget->loc.p) + 64;

                                // clang-format off
                                position_t new_pos
                                {
                                    PMob->loc.p.x - (cosf(rotationToRadian(angle)) * 1.5f),
                                    PTarget->loc.p.y,
                                    PMob->loc.p.z + (sinf(rotationToRadian(angle)) * 1.5f),
                                    0,
                                    0
                                };
                                // clang-format on

                                if (PMob->PAI->PathFind->ValidPosition(new_pos))
                                {
                                    PMob->PAI->PathFind->PathTo(new_pos, PATHFLAG_WALLHACK | PATHFLAG_RUN);
                                    needToMove = true;
                                }
                                break;
                            }
                        }
                    }

                    // Fix corner case where mob is attacking target at essentially exactly the distance that canMoveForward returns true at.
                    // where the mob doesn't rotate to face their target.
                    if (!needToMove)
                    {
                        FaceTarget();
                    }
                }
            }
            else
            {
                FaceTarget();
            }
        }
    }
    else
    {
        FaceTarget();
    }
}

void CMobController::HandleEnmity()
{
    TracyZoneScoped;
    PMob->PEnmityContainer->DecayEnmity();
    if (PMob->getMobMod(MOBMOD_SHARE_TARGET) > 0 && PMob->GetEntity(PMob->getMobMod(MOBMOD_SHARE_TARGET), TYPE_MOB))
    {
        ChangeTarget(static_cast<CMobEntity*>(PMob->GetEntity(PMob->getMobMod(MOBMOD_SHARE_TARGET), TYPE_MOB))->GetBattleTargetID());

        if (!PMob->GetBattleTargetID())
        {
            auto* PTarget{ PMob->PEnmityContainer->GetHighestEnmity() };
            ChangeTarget(PTarget ? PTarget->targid : 0);
        }
    }
    else
    {
        auto* PTarget{ PMob->PEnmityContainer->GetHighestEnmity() };
        if (PTarget)
        {
            ChangeTarget(PTarget->targid);
        }
    }
}

void CMobController::DoRoamTick(time_point tick)
{
    TracyZoneScopedC(0x00FF00);
    // If there's someone on our enmity list, go from roaming -> engaging
    if (PMob->PEnmityContainer->GetHighestEnmity() != nullptr && !(PMob->m_roamFlags & ROAMFLAG_IGNORE))
    {
        Engage(PMob->PEnmityContainer->GetHighestEnmity()->targid);
        return;
    }
    else if (PMob->m_OwnerID.id != 0 && !(PMob->m_roamFlags & ROAMFLAG_IGNORE))
    {
        // i'm claimed by someone and need hate towards this person
        PTarget = (CBattleEntity*)PMob->GetEntity(PMob->m_OwnerID.targid, TYPE_PC | TYPE_MOB | TYPE_PET | TYPE_TRUST);

        PMob->PEnmityContainer->AddBaseEnmity(PTarget);

        Engage(PTarget->targid);
        return;
    }
    //#TODO
    else if (PMob->GetDespawnTime() > time_point::min() && PMob->GetDespawnTime() < m_Tick)
    {
        Despawn();
        return;
    }

    if (PMob->m_roamFlags & ROAMFLAG_IGNORE)
    {
        // don't claim me if I ignore
        PMob->m_OwnerID.clean();
    }

    // skip roaming if waiting
    if (m_Tick >= m_WaitTime)
    {
        // don't aggro a little bit after I just disengaged
        PMob->m_neutral = PMob->CanBeNeutral() && m_Tick <= m_NeutralTime + 10s;

        if (PMob->PAI->PathFind->IsFollowingPath())
        {
            FollowRoamPath();
        }
        else if (PMob->PAI->PathFind->IsPatrolling())
        {
            PMob->PAI->PathFind->ResumePatrol();
            FollowRoamPath();
        }
        else if (m_Tick >= m_LastActionTime + std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_ROAM_COOL)))
        {
            // lets buff up or move around
            if (PMob->GetCallForHelpFlag())
            {
                PMob->SetCallForHelpFlag(false);
            }

            // can't rest with poison or disease
            if (PMob->CanRest() && PMob->getMobMod(MOBMOD_NO_REST) == 0)
            {
                // recover 10% health
                if (PMob->Rest(0.1f))
                {
                    // health updated
                    PMob->updatemask |= UPDATE_HP;
                }

                if (PMob->GetHPP() == 100)
                {
                    // at max health undirty exp
                    PMob->m_HiPCLvl     = 0;
                    PMob->m_HiPartySize = 0;
                    PMob->m_giveExp     = true;
                    PMob->m_UsedSkillIds.clear();
                }
            }

            // if I just disengaged check if I should despawn
            if (!PMob->getMobMod(MOBMOD_DONT_ROAM_HOME) && PMob->IsFarFromHome())
            {
                if (PMob->CanRoamHome() && PMob->PAI->PathFind->PathTo(PMob->m_SpawnPoint))
                {
                    // walk back to spawn if too far away

                    // limit total path to just 10 or
                    // else we'll move straight back to spawn
                    PMob->PAI->PathFind->LimitDistance(10.0f);

                    FollowRoamPath();

                    // move back every 5 seconds
                    m_LastActionTime = m_Tick - (std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_ROAM_COOL)) + 10s);
                }
                else if (!(PMob->getMobMod(MOBMOD_NO_DESPAWN) != 0) && !settings::get<bool>("map.MOB_NO_DESPAWN"))
                {
                    PMob->PAI->Despawn();
                    return;
                }
            }
            else
            {
                // No longer including conditional for ROAMFLAG_AMBUSH now that using mixin to handle mob hiding
                if (PMob->getMobMod(MOBMOD_SPECIAL_SKILL) != 0 &&
                    m_Tick >= m_LastSpecialTime + std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_SPECIAL_COOL)) && TrySpecialSkill())
                {
                    // I spawned a pet
                }
                else if (PMob->GetMJob() == JOB_SMN && CanCastSpells() && PMob->SpellContainer->HasBuffSpells() &&
                         m_Tick >= m_LastMagicTime + std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_MAGIC_COOL)))
                {
                    // summon pet
                    auto spellID = PMob->SpellContainer->GetBuffSpell();
                    if (spellID)
                    {
                        CastSpell(spellID.value());
                    }
                }
                else if (CanCastSpells() && xirand::GetRandomNumber(10) < 3 && PMob->SpellContainer->HasBuffSpells())
                {
                    // cast buff
                    auto spellID = PMob->SpellContainer->GetBuffSpell();
                    if (spellID)
                    {
                        CastSpell(spellID.value());
                    }
                }
                else if (PMob->m_roamFlags & ROAMFLAG_SCRIPTED)
                {
                    // allow custom event action
                    PMob->PAI->EventHandler.triggerListener("ROAM_ACTION", CLuaBaseEntity(PMob));
                    luautils::OnMobRoamAction(PMob);
                    m_LastActionTime = m_Tick;
                }
                else if (PMob->CanRoam() && PMob->PAI->PathFind->RoamAround(PMob->m_SpawnPoint, PMob->GetRoamDistance(),
                                                                            (uint8)PMob->getMobMod(MOBMOD_ROAM_TURNS), PMob->m_roamFlags))
                {
                    //#TODO: #AIToScript (event probably)
                    if (PMob->m_roamFlags & ROAMFLAG_WORM)
                    {
                        // move down
                        PMob->animationsub = 1;
                        PMob->HideName(true);
                        PMob->SetUntargetable(true);

                        // don't move around until i'm fully in the ground
                        Wait(2s);
                    }
                    else if ((PMob->m_roamFlags & ROAMFLAG_STEALTH))
                    {
                        // hidden name
                        PMob->HideName(true);
                        PMob->SetUntargetable(true);

                        PMob->updatemask |= UPDATE_HP;
                    }
                    else
                    {
                        FollowRoamPath();
                    }
                }
                else
                {
                    m_LastActionTime = m_Tick;
                }
            }
        }
    }
    if (m_Tick >= m_LastRoamScript + 3s)
    {
        PMob->PAI->EventHandler.triggerListener("ROAM_TICK", CLuaBaseEntity(PMob));
        luautils::OnMobRoam(PMob);
        m_LastRoamScript = m_Tick;
    }
}

void CMobController::Wait(duration _duration)
{
    if (m_Tick > m_WaitTime)
    {
        m_WaitTime = m_Tick += _duration;
    }
    else
    {
        m_WaitTime += _duration;
    }
}

void CMobController::FollowRoamPath()
{
    TracyZoneScoped;
    if (PMob->PAI->CanFollowPath())
    {
        PMob->PAI->PathFind->FollowPath(m_Tick);

        CBattleEntity* PPet = PMob->PPet;
        if (PPet != nullptr && PPet->PAI->IsSpawned() && !PPet->PAI->IsEngaged())
        {
            // pet should follow me if roaming
            position_t targetPoint = nearPosition(PMob->loc.p, 2.1f, (float)M_PI);

            PPet->PAI->PathFind->PathTo(targetPoint);
        }

        // if I just finished reset my last action time
        if (!PMob->PAI->PathFind->IsFollowingPath())
        {
            uint16 roamRandomness = (uint16)(PMob->getBigMobMod(MOBMOD_ROAM_COOL) / PMob->GetRoamRate());
            m_LastActionTime      = m_Tick - std::chrono::milliseconds(xirand::GetRandomNumber(roamRandomness));

            // i'm a worm pop back up
            if (PMob->m_roamFlags & ROAMFLAG_WORM)
            {
                PMob->animationsub = 0;
                PMob->HideName(false);
                PMob->SetUntargetable(false);
            }

            // face spawn rotation if I just moved back to spawn
            // used by dynamis mobs, bcnm mobs etc
            if (PMob->getMobMod(MOBMOD_ROAM_RESET_FACING) && distance(PMob->loc.p, PMob->m_SpawnPoint) <= PMob->m_maxRoamDistance)
            {
                PMob->loc.p.rotation = PMob->m_SpawnPoint.rotation;
            }
        }

        if (PMob->PAI->PathFind->OnPoint())
        {
            PMob->PAI->EventHandler.triggerListener("PATH", CLuaBaseEntity(PMob));
            luautils::OnPath(PMob);
        }
    }
}

void CMobController::Despawn()
{
    TracyZoneScoped;
    if (PMob)
    {
        PMob->PAI->Internal_Despawn();
    }
}

void CMobController::Reset()
{
    TracyZoneScoped;
    // Wait a little before roaming / casting spell / spawning pet
    m_LastActionTime = m_Tick - std::chrono::milliseconds(xirand::GetRandomNumber(PMob->getBigMobMod(MOBMOD_ROAM_COOL)));

    // Don't attack player right off of spawn
    PMob->m_neutral = true;
    m_NeutralTime   = m_Tick;

    PTarget = nullptr;
}

bool CMobController::MobSkill(uint16 targid, uint16 wsid)
{
    TracyZoneScoped;
    if (POwner)
    {
        FaceTarget(targid);
        PMob->PAI->EventHandler.triggerListener("WEAPONSKILL_BEFORE_USE", PMob, wsid);
        return POwner->PAI->Internal_MobSkill(targid, wsid);
    }

    return false;
}

bool CMobController::Disengage()
{
    TracyZoneScoped;
    // this will let me decide to walk home or despawn
    m_LastActionTime = m_Tick - std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_ROAM_COOL)) + 10s;
    PMob->m_neutral  = true;
    m_NeutralTime    = m_Tick;

    PMob->PAI->PathFind->Clear();
    PMob->PEnmityContainer->Clear();

    if (PMob->getMobMod(MOBMOD_IDLE_DESPAWN))
    {
        PMob->SetDespawnTime(std::chrono::seconds(PMob->getMobMod(MOBMOD_IDLE_DESPAWN)));
    }

    PMob->m_OwnerID.clean();
    PMob->updatemask |= (UPDATE_STATUS | UPDATE_HP);
    PMob->SetCallForHelpFlag(false);
    PMob->animation = ANIMATION_NONE;

    return CController::Disengage();
}

bool CMobController::Engage(uint16 targid)
{
    TracyZoneScoped;
    auto ret = CController::Engage(targid);
    if (ret)
    {
        m_firstSpell = true;

        // Don't cast magic or use special ability right away
        if (PMob->getBigMobMod(MOBMOD_MAGIC_DELAY) != 0)
        {
            m_LastMagicTime =
                m_Tick - std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_MAGIC_COOL) + xirand::GetRandomNumber(PMob->getBigMobMod(MOBMOD_MAGIC_DELAY)));
        }

        if (PMob->getBigMobMod(MOBMOD_SPECIAL_DELAY) != 0)
        {
            m_LastSpecialTime = m_Tick - std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_SPECIAL_COOL) +
                                                                   xirand::GetRandomNumber(PMob->getBigMobMod(MOBMOD_SPECIAL_DELAY)));
        }
    }
    return ret;
}

bool CMobController::CanAggroTarget(CBattleEntity* PTarget)
{
    TracyZoneScoped;
    TracyZoneIString(PMob->GetName());
    TracyZoneIString(PTarget->GetName());

    // Don't aggro I'm neutral
    if ((PMob->getMobMod(MOBMOD_ALWAYS_AGGRO) == 0 && !PMob->m_Aggro) || PMob->m_neutral || PMob->isDead())
    {
        return false;
    }

    // Don't aggro I'm special
    if (PMob->getMobMod(MOBMOD_NO_AGGRO) > 0)
    {
        return false;
    }

    // Don't aggro I'm an underground worm
    if ((PMob->m_roamFlags & ROAMFLAG_WORM) && PMob->IsNameHidden())
    {
        return false;
    }

    if (PTarget->isDead() || PTarget->isMounted())
    {
        return false;
    }

    return PMob->PMaster == nullptr && PMob->PAI->IsSpawned() && !PMob->PAI->IsEngaged() && CanDetectTarget(PTarget);
}

void CMobController::TapDeaggroTime()
{
    m_DeaggroTime = m_Tick;
}

void CMobController::TapDeclaimTime()
{
    m_DeclaimTime = m_Tick;
}

bool CMobController::Cast(uint16 targid, SpellID spellid)
{
    TracyZoneScoped;
    FaceTarget(targid);
    return CController::Cast(targid, spellid);
}

bool CMobController::CanMoveForward(float currentDistance)
{
    TracyZoneScoped;
    if (PMob->m_Behaviour & BEHAVIOUR_STANDBACK && currentDistance < 20)
    {
        return false;
    }

    if (PMob->getMobMod(MOBMOD_NO_STANDBACK) == 0 && PMob->getMobMod(MOBMOD_HP_STANDBACK) > 0 && currentDistance < 20 &&
        PMob->GetHPP() >= PMob->getMobMod(MOBMOD_HP_STANDBACK))
    {
        // Excluding Nins, mobs should not standback if can't cast magic
        return PMob->GetMJob() != JOB_NIN && PMob->SpellContainer->HasSpells() && !CanCastSpells();
    }

    if (PMob->getMobMod(MOBMOD_SPAWN_LEASH) > 0 && distance(PMob->loc.p, PMob->m_SpawnPoint) > PMob->getMobMod(MOBMOD_SPAWN_LEASH))
    {
        return false;
    }

    return true;
}

bool CMobController::IsSpecialSkillReady(float currentDistance)
{
    TracyZoneScoped;
    if (PMob->getMobMod(MOBMOD_SPECIAL_SKILL) == 0)
    {
        return false;
    }

    if (PMob->StatusEffectContainer->HasStatusEffect(EFFECT_CHAINSPELL))
    {
        return false;
    }

    int32 bonusTime = 0;
    if (currentDistance > 5)
    {
        // Mobs use ranged attacks quicker when standing back
        bonusTime = PMob->getBigMobMod(MOBMOD_STANDBACK_COOL);
    }

    return m_Tick >= m_LastSpecialTime + std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_SPECIAL_COOL) - bonusTime);
}

bool CMobController::IsSpellReady(float currentDistance)
{
    TracyZoneScoped;
    int32 bonusTime = 0;
    if (currentDistance > 5)
    {
        // Mobs use ranged attacks quicker when standing back
        bonusTime = PMob->getBigMobMod(MOBMOD_STANDBACK_COOL);
    }

    if (PMob->StatusEffectContainer->HasStatusEffect({ EFFECT_CHAINSPELL, EFFECT_MANAFONT }))
    {
        return true;
    }

    return (m_Tick >= m_LastMagicTime + std::chrono::milliseconds(PMob->getBigMobMod(MOBMOD_MAGIC_COOL) - bonusTime));
}
