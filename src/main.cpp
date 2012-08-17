/*
 * Copyright (c) 2010-2012 OTClient <https://github.com/edubart/otclient>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#include <framework/core/application.h>
#include <framework/core/resourcemanager.h>
#include <framework/luaengine/luainterface.h>
#include <framework/platform/platformwindow.h>
#include <framework/ui/ui.h>
#include <framework/graphics/fontmanager.h>
#include <framework/core/configmanager.h>
#include <otclient/otclient.h>

void initInterface()
{
    UIWidgetPtr label(new UIWidget);
    label->setText("Hello world");
    label->move(10, 10);
    label->setBackgroundColor(Color::pink);
    g_ui.getRootWidget()->addChild(label);
}

void init()
{
    // setup log file
    g_logger.setLogFile(g_resources.getWorkDir() + g_app.getCompactName() + ".log");

    // print version
    g_logger.info(g_app.getName() + " " + g_app.getVersion() + " rev " + g_app.getBuildRevision() + " (" + g_app.getBuildCommit() + ") built on " + g_app.getBuildDate() + " for arch " + g_app.getBuildArch());

    // find working directory, the directory that contains fmerc.lua
    g_resources.discoverWorkDir(g_app.getCompactName(), "fmerc.lua");

    // add current directory to the search path
    g_resources.addSearchPath(g_resources.getWorkDir());

    // load configs
    g_configs.load("/config.otml");

    // setup window
    g_window.setMinimumSize(Size(600, 480));
    g_window.setTitle("Forgotten Map Editor");

    // load font
    g_fonts.importFont("/data/fonts/verdana-11px-antialised.otfont");
    g_fonts.setDefaultFont("verdana-11px-antialised");
}

int main(int argc, const char* argv[])
{
    std::vector<std::string> args(argv, argv + argc);

    // setup application name and version
    g_app.setName("Forgotten Map Editor");
    g_app.setCompactName("fme");
    g_app.setVersion("0.1.0_dev");

    // initialize application framework and otclient
    g_app.init(args);
    g_otclient.init(args);

    init();

    /*
    // find script init.lua and run it
    g_resources.discoverWorkDir(g_app.getCompactName(), "init.lua");
    if(!g_lua.safeRunScript(g_resources.getWorkDir() + "init.lua"))
        g_logger.fatal("Unable to run script init.lua!");
    */

    // the run application main loop
    g_app.run();

    // unload modules
    g_app.deinit();

    // terminate everything and free memory
    g_otclient.terminate();
    g_app.terminate();
    return 0;
}