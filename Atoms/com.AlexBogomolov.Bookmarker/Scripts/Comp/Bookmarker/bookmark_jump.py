"""
Jump to stored flow position. Use dropdown menu to switch to stored position
KEY FEATURES:
* Delete single bookmark or all of them
* All bookmarks are alphabetically sorted.
* Add a bookmark from Jump UI with plus button. Press Refresh and new bookmarkk will appear in a list
* To jump the same tool once again just select it again in a list.
v 2.5 update:
* Move selected tools next to bookmark position (enable checkbox 'move selected to bookmark')
* Jump back and forth between previous and current bookmarks

KNOWN ISSUES:
* depending on complexity if the comp, the nodes in a flow
may temporarily disappear after bookmark jump. As a workaround to this issue
added 0.2 sec delay before jump to the tool.
* the script just finds a tool in a flow and makes it active. It does not center it in the flow.
Possible workaround here:
-- jump to the tool, click on the flow, press CTRL/CMD+F and then hit ENTER
-- right click the flow with node selected, Scale -> Scale to Fit

Alexey Bogomolov mail@abogomolov.com
Requests and issues: https://gitlab.com/WeSuckLess/Reactor/tree/movalex/Atoms/com.AlexBogomolov.Bookmarker
Donations are highly appreciated: https://paypal.me/aabogomolov
STU topic and discussion, feature requests and updates: https://www.steakunderwater.com/wesuckless/viewtopic.php?f=33&t=2858

MIT License: https://mit-license.org/
"""
# legacy python reporting compatibility
from __future__ import print_function
import time

flow = comp.CurrentFrame.FlowView

# close UI on ESC button
comp.Execute('''app:AddConfig("combobox",
{
Target  {ID = "combobox"},
Hotkeys {Target = "combobox",
         Defaults = true,
         ESCAPE = "Execute{cmd = [[app.UIManager:QueueEvent(obj, 'Close', {})]]}" }})
''')


def parse_data(_data):
    # return sorted by bookmark
    strip_data = list(_data.values())
    parsed_data = sorted(
        [list(i.values()) for i in strip_data],
        key=lambda x: x[0].lower())
    return parsed_data


def prefill_combobox():
    itm['MyCombo'].Clear()
    message = 'select bookmark'
    if not data:
        message = 'add some bookmarks!'
    itm['MyCombo'].AddItem(message)
    itm['MyCombo'].InsertSeparator()


def fill_combobox(fill_data):
    prefill_combobox()
    if fill_data:
        sorted_bms = [i[0] for i in parse_data(fill_data)]
        for bkm in sorted_bms:
            itm['MyCombo'].AddItem(bkm)


def delete_bookmark(key):
    comp.SetData('BM')
    del data[key]
    for k, v in data.items():
        comp.SetData('BM.{}'.format(k), v)


def move_selected_to_bm(tools=None, target=None):
    # print(itm['moveCB'].Checked)
    if tools and target:
        comp.StartUndo('Move tool to BM')
        pos_targetx, pos_targety = flow.GetPosTable(target).values()
        for n, selected_tool in enumerate(tools):
            flow.SetPos(selected_tool, pos_targetx + (n+1), pos_targety)
        comp.EndUndo()


def jump_bookmark(ev):
    choice = int(itm['MyCombo'].CurrentIndex)
    if choice > 1 and data:
        tool_data = parse_data(data)[choice - 2]
        bm_name, tool_name, scale_factor, _ = tool_data
        # print('jump to', tool_name)
        target = comp.FindTool(tool_name)
        active = comp.ActiveTool
        if target and target.GetAttrs('TOOLB_Selected'):
            # print('tool already selected, now jumping back')
            flow.Select()
        if active:
            comp.SetData('PrevBM', active.Name)
            flow.Select()
        flow.SetScale(scale_factor)
        selected_before_jump = list(comp.GetToolList(True).values())
        time.sleep(.2)
        comp.SetActiveTool(target)
    if itm['moveCB'].Checked:
        move_selected_to_bm(selected_before_jump, target)


def jump_back(ev):
    prev = comp.GetData('PrevBM')
    jump_to = comp.FindTool(prev)
    current = comp.ActiveTool
    if prev and prev != current:
        comp.SetActiveTool(jump_to)
        comp.SetData('PrevBM', current.Name)
    else:
        print('no previous tool found')


def close(ev):
    disp.ExitLoop()


def clear_all_bookmarks(ev):
    comp.SetData('BM')
    print('all your bookmarks are belong to us')
    itm['MyCombo'].Clear()
    itm['MyCombo'].AddItem('add some bookmarks!')


def delete_bookmark_event(ev):
    choice = int(itm['MyCombo'].CurrentIndex)
    if choice > 0:
        bm_text, tool_id = parse_data(data)[choice - 2][::3]
        itm['MyCombo'].RemoveItem(choice)
        print('bookmark {} deleted'.format(bm_text))
        delete_bookmark(tool_id)
        if len(data) == 0:
            prefill_combobox()
            print('no bookmarks left')


def refresh_list(ev):
    global data
    check_data = comp.GetData('BM')
    if check_data and check_data != data:
        print('updating bookmarks')
        itm['MyCombo'].Clear()
        data = check_data
        fill_combobox(data)
    else:
        print('nothing changed')


def add_bookmark_run(ev):
    comp.RunScript('Scripts:Comp/Bookmarker/bookmark_add.py')


if __name__ == '__main__':
    data = comp.GetData('BM')
    if not data:
        data = {}
        print('add some bookmarks!')
    x, y  = fu.GetMousePos().values()
    if y < 90:
        y = 120

    # Main Window
    ui = fusion.UIManager
    disp = bmd.UIDispatcher(ui)
    btn_icon_size = 0
    win = disp.AddWindow(
        {'ID': 'combobox',
         'TargetID': 'combobox',
         'WindowTitle': 'jump to bookmark',
         'Geometry': [x, y, 300, 95]},
        [
            ui.VGroup(
                [
                    ui.HGroup(
                        [
                            ui.ComboBox({'ID': 'MyCombo',
                                         'Text': 'Choose preset',
                                         'Events': {'Activated': True},
                                         'Weight': .8}),
                            ui.Button({'ID': 'AddButton',
                                       'Flat': False,
                                       'IconSize': [12, 12],
                                       'MinimumSize': [20, 12],
                                       'Icon': ui.Icon({'File':
                                                        'Scripts:Comp/Bookmarker/icons/plus_icon.png'}),
                                       'Weight': .1
                                       }),
                            ui.Button({'ID': 'refreshButton',
                                       'Flat': False,
                                       'IconSize': [12, 12],
                                       'MinimumSize': [20, 12],
                                       'Icon': ui.Icon({'File':
                                                        'Scripts:Comp/Bookmarker/icons/refresh_icon.png',
                                                        }),
                                       'Weight': .1
                                       }),
                        ]),
                    ui.HGroup(
                        [
                            ui.Button({'ID': 'jb',
                                       'Text': 'jump back',
                                       'Weight': 0.5,
                                       }),
                            ui.Button({'ID': 'rm',
                                       'Text': 'delete one',
                                       'Weight': 0.3,
                                       }),
                            ui.Button({'ID': 'rmall',
                                       'Text': 'reset all',
                                       'Weight': 0.2,
                                       }),
                        ]),
                    ui.HGroup(
                        [
                            ui.CheckBox({'ID': 'moveCB',
                                         'Text': 'move selected to bookmark?',
                                         })
                        ])
                ]),
        ])

    itm = win.GetItems()

    win.On.MyCombo.Activated = jump_bookmark
    win.On.rm.Clicked = delete_bookmark_event
    win.On.rmall.Clicked = clear_all_bookmarks
    win.On.jb.Clicked = jump_back
    win.On.combobox.Close = close
    win.On.refreshButton.Clicked = refresh_list
    win.On.AddButton.Clicked = add_bookmark_run
    fill_combobox(data)

    win.Show()
    disp.RunLoop()
    win.Hide()

