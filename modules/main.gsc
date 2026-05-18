#precache("lui_menu_data", "frontend")

function init()
{
    level thread boot_frontend();
}

function boot_frontend()
{
    wait 2;

    // force frontend to rebuild using your override
    Engine.Exec("openmenu frontend");
}