/*  SM Slow fire
 *
 *  Copyright (C) 2017 Francisco 'Franc1sco' García
 * 
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 3 of the License, or (at your option) 
 * any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT 
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with 
 * this program. If not, see http://www.gnu.org/licenses/.
 */

#include <sourcemod>
#include <sdkhooks>
#include <zombiereloaded>
#include <zr_tools>

new Handle:Timers[MAXPLAYERS + 1] = INVALID_HANDLE;

new Float:fireMovementSpeed = 0.6;

public Plugin:myinfo = 
{
	name = "SM Slow fire",
	author = "Franc1sco steam: franug",
	description = "Slow fire",
	version = "2.0",
	url = "http://steamcommunity.com/id/franug"
};

public OnPluginStart()
{
	CreateConVar("sm_SlowFire", "2.0", "Version", FCVAR_NOTIFY | FCVAR_DONTRECORD | FCVAR_CHEAT);
	
	for(int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i))
		{
			OnClientPutInServer(i);
		}
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action:OnTakeDamage(client, &attacker, &inflictor, &Float:damage, &damagetype)
{
	if(damagetype & DMG_BURN && IsPlayerAlive(client) && ZR_IsClientZombie(client))
	{
		if (Timers[client] == INVALID_HANDLE)
		{
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fireMovementSpeed);
			Timers[client] = CreateTimer(0.3, Stop, client);
		}
		else
		{
			KillTimer(Timers[client]);
			Timers[client] = INVALID_HANDLE;
		
			SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", fireMovementSpeed);
			Timers[client] = CreateTimer(0.3, Stop, client);
		}
	}
}

public Action:Stop(Handle:timer, any:client)
{
	Timers[client] = INVALID_HANDLE;
	if(IsClientInGame(client) && IsPlayerAlive(client))
	{
		float velocidad = ZRT_GetClientAttributeValueFloat(client, "speed", 300.0);
		SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", velocidad/300.0);
	}
}

public OnClientDisconnect(client)
{
	if (Timers[client] != INVALID_HANDLE)
    {
		KillTimer(Timers[client]);
		Timers[client] = INVALID_HANDLE;
	}
}
