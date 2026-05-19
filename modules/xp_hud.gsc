function init_hud()
{
    self endon("disconnect");

    self.xp_bar_max_width = 260;
    self.xp_bar_height = 16;
    self.xp_y_offset = -30;

    self.xp_bar_current_width = 0;

    self.xp_bar_bg = newClientHudElem(self);
    self.xp_bar_bg.horzAlign = "center";
    self.xp_bar_bg.vertAlign = "bottom";
    self.xp_bar_bg.alignX = "center";
    self.xp_bar_bg.alignY = "bottom";
    self.xp_bar_bg.x = 0;
    self.xp_bar_bg.y = self.xp_y_offset;
    self.xp_bar_bg.alpha = 0.65;
    self.xp_bar_bg.color = (0.05, 0.05, 0.05);
    self.xp_bar_bg setShader("white", self.xp_bar_max_width, self.xp_bar_height);

    self.xp_bar_fill = newClientHudElem(self);
    self.xp_bar_fill.horzAlign = "center";
    self.xp_bar_fill.vertAlign = "bottom";
    self.xp_bar_fill.alignX = "left";
    self.xp_bar_fill.alignY = "bottom";
    self.xp_bar_fill.x = -(self.xp_bar_max_width / 2);
    self.xp_bar_fill.y = self.xp_y_offset;
    self.xp_bar_fill.alpha = 1;
    self.xp_bar_fill.color = (0, 0.7, 1);
    self.xp_bar_fill setShader("white", 1, self.xp_bar_height);

    self.xp_level_text = newClientHudElem(self);
    self.xp_level_text.horzAlign = "center";
    self.xp_level_text.vertAlign = "bottom";
    self.xp_level_text.alignX = "center";
    self.xp_level_text.alignY = "bottom";
    self.xp_level_text.x = 0;
    self.xp_level_text.y = self.xp_y_offset - 18;
    self.xp_level_text.font = "default";
    self.xp_level_text.fontScale = 1.5;

    self.xp_text = newClientHudElem(self);
    self.xp_text.horzAlign = "center";
    self.xp_text.vertAlign = "bottom";
    self.xp_text.alignX = "center";
    self.xp_text.alignY = "bottom";
    self.xp_text.x = 0;
    self.xp_text.y = self.xp_y_offset + 18;
    self.xp_text.font = "default";
    self.xp_text.fontScale = 1.2;

    self thread xp_hud_bar_loop();
    self thread xp_update_listener();
    self thread xp_levelup_listener();

    self thread update_hud_values();
}

function xp_hud_bar_loop()
{
    self endon("disconnect");

    while (true)
    {
        if (!isdefined(self.xp) || !isdefined(self.xp_needed) || self.xp_needed <= 0)
        {
            wait 0.05;
            continue;
        }

        progress = self.xp / self.xp_needed;

        if (progress < 0) progress = 0;
        if (progress > 1) progress = 1;

        target_width = self.xp_bar_max_width * progress;

        self.xp_bar_current_width += (target_width - self.xp_bar_current_width) * 0.25;

        self.xp_bar_fill setShader(
            "white",
            int(self.xp_bar_current_width),
            self.xp_bar_height
        );

        wait 0.05;
    }
}

function xp_update_listener()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("xp_update", amount, hit_location);

        self thread xp_fly_label(amount, hit_location);

        self thread update_hud_values();
    }
}

function xp_levelup_listener()
{
    self endon("disconnect");

    while (true)
    {
        self waittill("xp_level_up");

        self thread xp_levelup_popup();
        self thread update_hud_values();
    }
}

function update_hud_values()
{
    if (!isdefined(self.xp) || !isdefined(self.xp_needed))
        return;

    self.xp_level_text setText("LEVEL " + self.xp_level);
    self.xp_text setText(self.xp + " / " + self.xp_needed);
}

function xp_fly_label(amount, hit_location)
{
    hud = newClientHudElem(self);
    hud.horzAlign = "center";
    hud.vertAlign = "bottom";
    hud.alignX = "center";
    hud.alignY = "bottom";
    hud.x = 0;
    hud.y = self.xp_y_offset - 40;
    hud.font = "default";
    hud.fontScale = 1.4;
    hud.alpha = 1;

    if (hit_location == "head" || hit_location == "helmet")
        hud.color = (1, 0.85, 0);
    else
        hud.color = (0, 1, 0);

    hud setText("+" + amount + " XP");

    hud moveOverTime(0.6);
    hud.y = hud.y - 40;

    wait 0.3;

    hud fadeOverTime(0.3);
    hud.alpha = 0;

    wait 0.3;

    hud destroy();
}

function xp_levelup_popup()
{
    hud = newClientHudElem(self);
    hud.horzAlign = "center";
    hud.vertAlign = "middle";
    hud.alignX = "center";
    hud.alignY = "middle";
    hud.font = "default";
    hud.fontScale = 2.2;
    hud.alpha = 1;
    hud.color = (0.2, 0.8, 1);

    hud setText("LEVEL UP!");

    hud moveOverTime(0.4);
    hud.y = -40;

    wait 0.4;

    hud fadeOverTime(0.5);
    hud.alpha = 0;

    wait 0.5;

    hud destroy();
}
