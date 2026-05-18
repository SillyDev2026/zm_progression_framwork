#using scripts\zm\xp_system;

function init()
{
    iprintln("MAIN ACTIVE");

    level thread xp_system::init();
}