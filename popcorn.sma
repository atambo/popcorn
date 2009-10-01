#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
new solo, newsolo, solo2, newsolo2, firstround, secondt = 0
public plugin_init()
{	
	register_plugin("popcorn", "1", "atambo")
	register_cvar("sv_popcorn", "0")
	register_cvar("sv_secondtnum", "5")
	register_concmd("amx_popcorn","toggle",ADMIN_CVAR,"1=on/0=off")
	register_event("DeathMsg", "death_event", "a")
	register_logevent("event_round_end", 2, "0=World triggered", "1=Round_End")
	register_menucmd(register_menuid("Team_Select",1), (1<<0)|(1<<1)|(1<<4)|(1<<5), "team_select")
    register_clcmd("jointeam", "join_team")
}
public client_connected_msg(id)
	client_print(id, print_chat, "Popcorn Mod is currently enabled. Kill the terrorist to become the next terrorist.")
public client_putinserver(id)
	if(get_cvar_num("sv_popcorn") == 1)
		set_task(20.0, "client_connected_msg", id)
public toggle(id,level,cid)
{
	if(!cmd_access(id,level,cid,2))
		return PLUGIN_HANDLED
	new arg1[32]
	read_argv(1,arg1,31)
	if(equali(arg1,"1"))
	{
		if(get_cvar_num("sv_popcorn") == 1) return PLUGIN_CONTINUE
		set_hudmessage(0, 100, 0, -1.0, 0.65, 2, 0.02, 10.0, 0.01, 0.1, 2)
		show_hudmessage(0,"Popcorn Mode Enabled!")
		set_cvar_num("mp_limitteams",0)
		set_cvar_num("mp_autoteambalance",0)
		set_cvar_num("sv_popcorn",1)
		firstround=1
		secondt=0
		set_cvar_num("sv_restart",1)
		event_round_end()
		return PLUGIN_CONTINUE
	}
	if(equali(arg1,"0"))
	{
		if(get_cvar_num("sv_popcorn") == 0) return PLUGIN_CONTINUE
		set_hudmessage(0, 100, 0, -1.0, 0.65, 2, 0.02, 10.0, 0.01, 0.1, 2)
		show_hudmessage(0,"Popcorn Mode Disabled!")
		set_cvar_num("mp_limitteams",1)
		set_cvar_num("mp_autoteambalance",1)
		set_cvar_num("sv_popcorn",0)
		set_cvar_num("sv_restartround",1)
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}
public team_select(id, key)
{
	if(get_cvar_num("sv_popcorn") != 1) return PLUGIN_CONTINUE
	if(key==0 || key==4)
	{
		engclient_cmd(id,"chooseteam")
		return PLUGIN_HANDLED
	}
    return PLUGIN_CONTINUE
}
public join_team(id)
{
	if(get_cvar_num("sv_popcorn") != 1) return PLUGIN_CONTINUE
	new arg[2]
	read_argv(1,arg,1)
	if((str_to_num(arg)-1)==0 || (str_to_num(arg)-1)==4)
	{
		engclient_cmd(id,"chooseteam")
		return PLUGIN_HANDLED
	}
    return PLUGIN_CONTINUE
}
public death_event()
{
	if(get_cvar_num("sv_popcorn") != 1) return PLUGIN_CONTINUE
	if(secondt)
	{
		if(read_data(2)==newsolo2)
		{
			newsolo2 = read_data(1)
   			solo2 = read_data(2)
		}
		if(read_data(2)==newsolo)
		{
			newsolo = read_data(1)
			solo = read_data(2)
		}
		return PLUGIN_CONTINUE
	}
	newsolo = read_data(1)
	solo = read_data(2)
	return PLUGIN_CONTINUE
}
public event_round_end()
{
	if(get_cvar_num("sv_popcorn") != 1) return PLUGIN_CONTINUE
	if(firstround==1)
	{
		new playersT[32], playersCT[32], numT, numCT
		get_players(playersT,numT,"e","TERRORIST")
		for(new i=0;i<numT;i++)
			cs_set_user_team(playersT[i],CS_TEAM_CT)
		get_players(playersCT,numCT,"e","CT")
		newsolo = random_num(0,numCT-1)
		cs_set_user_team(playersCT[newsolo],CS_TEAM_T)
		firstround=0
	}
	else
	{
		if(newsolo==solo || newsolo==0)
		{
			new playersCT[32], numCT
			get_players(playersCT,numCT,"e","CT")
			newsolo = random_num(0,numCT-1)
			cs_set_user_team(playersCT[newsolo],CS_TEAM_T)
			cs_set_user_team(solo,CS_TEAM_CT)
		}
		if(newsolo2==solo2 || newsolo2==0 && secondt==1)
		{
			new playersCT[32], numCT
			get_players(playersCT,numCT,"e","CT")
			newsolo2 = random_num(0,numCT-1)
			cs_set_user_team(playersCT[newsolo2],CS_TEAM_T)
			cs_set_user_team(solo2,CS_TEAM_CT)
		}
		else
		{
			if(secondt)
			{
				cs_set_user_team(newsolo2,CS_TEAM_T)
				cs_set_user_team(solo2,CS_TEAM_CT)
			}
			cs_set_user_team(newsolo,CS_TEAM_CT)
			cs_set_user_team(solo,CS_TEAM_T)
		}
	}
	if(get_playersnum()>=get_cvar_num("sv_secondtnum") && secondt!=1)
	{
		new playersCT[32], numCT
		secondt=1
		get_players(playersCT,numCT,"e","CT")
		newsolo2 = random_num(0,numCT-1)
		cs_set_user_team(playersCT[newsolo2],CS_TEAM_T)
	}
	if(get_playersnum()<get_cvar_num("sv_secondtnum") && secondt!=0)
	{
		secondt=0
		cs_set_user_team(newsolo,CS_TEAM_CT)
	}
	return PLUGIN_CONTINUE
}
public plugin_end()
{
	set_cvar_num("mp_limitteams",1)
	set_cvar_num("mp_autoteambalance",1)
	set_cvar_num("sv_popcorn",0)
}