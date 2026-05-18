#using scripts\zm\xp_hud;
#using scripts\codescripts\struct;

#using scripts\shared\system_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;

#using scripts\zm\gametypes\_globallogic;
#using scripts\zm\gametypes\_globallogic_score;

/* =========================================================
   INIT
========================================================= */

function init()
{
    level thread xp_connect_monitor();
    level thread round_end_save();
}

/* =========================================================
   PLAYER CONNECT
========================================================= */

function xp_connect_monitor()
{
    level endon("game_ended");

    while (true)
    {
        level waittill("connected", player);

        if (!isdefined(player))
            continue;

        if (isdefined(player.xp_initialized))
            continue;

        player.xp_initialized = true;

        player.guid = player GetGuid();

        player thread init_player_xp();
        player thread xp_autosave_loop();
        player thread xp_notify_listener();
    }
}

/* =========================================================
   PLAYER INIT
========================================================= */

function init_player_xp()
{
    self endon("disconnect");

    self waittill("spawned_player");

    xp  = get_xp_stat(self, "xp");
    lvl = get_xp_stat(self, "xp_level");

    if (!isdefined(xp))
        xp = 0;

    if (!isdefined(lvl) || lvl < 1)
        lvl = 1;

    self.xp = int(xp);
    self.xp_level = int(lvl);

    if (self.xp < 0)
        self.xp = 0;

    self.xp_needed = calc_xp_needed(self.xp_level);

    self thread xp_hud::init_hud();

    iprintlnbold("XP SYSTEM LOADED");

    iprintln("[XP_LOAD]" + self.guid + "," + self.xp + "," + self.xp_level + "\n");
}

/* =========================================================
   LUA -> GSC NOTIFY LISTENER
========================================================= */

function xp_notify_listener()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("xp_add", amount);

        if (!isdefined(amount))
            amount = 0;

        amount = int(amount);

        if (amount <= 0)
            continue;

        self thread add_xp(amount, "script");
    }
}

/* =========================================================
   XP REQUIRED
========================================================= */

function calc_xp_needed(lvl)
{
    return int(80 + (lvl * 25) + (lvl * lvl * 8));
}

/* =========================================================
   ADD XP
========================================================= */

function add_xp(amount, hit_location)
{
    if (!isdefined(self))
        return;

    if (!isdefined(self.xp))
        self.xp = 0;

    if (!isdefined(self.xp_level))
        self.xp_level = 1;

    if (!isdefined(self.xp_needed))
        self.xp_needed = calc_xp_needed(self.xp_level);

    amount = int(amount);

    if (amount <= 0)
        return;

    self.xp += amount;

    self notify("xp_update", amount, hit_location);

    while (self.xp >= self.xp_needed)
    {
        self.xp -= self.xp_needed;

        self.xp_level++;

        self.xp_needed = calc_xp_needed(self.xp_level);

        self notify("xp_level_up");

        iprintlnbold("LEVEL UP! Level " + self.xp_level);
    }

    self save_xp();
}

/* =========================================================
   HIT LOCATION XP
========================================================= */

function get_xp_from_hit(hit_location)
{
    switch (hit_location)
    {
        case "head":
        case "helmet":
            return 15;

        case "neck":
            return 10;

        case "torso_upper":
            return 8;

        case "torso_lower":
            return 5;

        default:
            return 3;
    }
}

/* =========================================================
   ON KILL
========================================================= */

function on_kill(hit_location)
{
    amount = get_xp_from_hit(hit_location);

    self thread add_xp(amount, hit_location);

    self notify("xp_changed", amount, hit_location);
}

/* =========================================================
   SAVE XP
========================================================= */

function save_xp()
{
    if (!isdefined(self))
        return;

    if (!isdefined(self.guid))
        self.guid = self GetGuid();

    set_xp_stat(self, "xp", self.xp);
    set_xp_stat(self, "xp_level", self.xp_level);

    self.last_saved_xp = self.xp;
    self.last_saved_level = self.xp_level;

    iprintln(
        "[XP_SAVE]" +
        self.guid + "," +
        self.xp + "," +
        self.xp_level + "\n"
    );
}

/* =========================================================
   ROUND END SAVE
========================================================= */

function round_end_save()
{
    level endon("game_ended");

    while (true)
    {
        level waittill("end_of_game");

        foreach (player in level.players)
        {
            if (isdefined(player))
                player save_xp();
        }
    }
}

/* =========================================================
   AUTOSAVE
========================================================= */

function xp_autosave_loop()
{
    self endon("disconnect");
    level endon("game_ended");

    while (true)
    {
        wait 60;

        self save_xp();
    }
}

/* =========================================================
   GET XP STAT
========================================================= */

function get_xp_stat(player, stat_name)
{
    key = get_player_key(player, stat_name);

    value = GetDVarInt(key);

    return value;
}

/* =========================================================
   SET XP STAT
========================================================= */

function set_xp_stat(player, stat_name, value)
{
    key = get_player_key(player, stat_name);

    SetDVar(key, int(value));
}

/* =========================================================
   PLAYER KEY
========================================================= */

function get_player_key(player, stat)
{
    guid = player.guid;

    if (!isdefined(guid))
        guid = player GetGuid();

    return "xp_" + guid + "_" + stat;
}