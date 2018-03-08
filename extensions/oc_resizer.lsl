/*------------------------------------------------------------------------------

 Resizer, Build 12

 Wendy's OpenCollar Distribution
 https://github.com/wendystarfall/opencollar

--------------------------------------------------------------------------------

 OpenCollar v1.000 - v3.600 (OpenCollar - submission set free):

 Copyright © 2008, 2009, 2010 Cleo Collins, Garvin Twine, Lulu Pink,
 Master Starship, Nandana Singh, et al.

 The project in its original form concluded on October 19, 2011. Everything past
 this date is a derivative of OpenCollar's original SVN trunk from Google Code.

--------------------------------------------------------------------------------

 OpenCollar v3.700 - v3.720 (nirea's ocupdater):

 Copyright © 2011 nirea, Satomi Ahn

 https://github.com/OpenCollarUpdates/ocupdater/commits/release

--------------------------------------------------------------------------------

 OpenCollar v3.750 - v3.809 (Satomi's OpenCollarUpdates):

 Copyright © 2012 Satomi Ahn

 https://github.com/OpenCollarUpdates/ocupdater/commits/3.8
 https://github.com/OpenCollarUpdates/ocupdater/commits/beta

--------------------------------------------------------------------------------

 OpenCollar v3.809 - v3.843 (Joy's OpenCollar Evolution):

 Copyright © 2013 Joy Stipe

 https://github.com/JoyStipe/ocupdater/commits/Project_Evolution

--------------------------------------------------------------------------------

 OpenCollar v3.844 - v3.998 (Wendy's OpenCollar API 3.9):

 Copyright © 2013 Wendy Starfall
 Copyright © 2014 littlemousy, Romka Swallowtail, Wendy Starfall

 https://github.com/OpenCollar/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 Virtual Disgrace Collar v1.0.0 - v2.1.1 (virtualdisgrace.com):

 Copyright © 2011, 2012, 2013 Wendy Starfall
 Copyright © 2014 littlemousy, Wendy Starfall

 https://github.com/WendyStarfall/opencollar/commits/master
 https://github.com/VirtualDisgrace/opencollar/commits/master

--------------------------------------------------------------------------------

 OpenCollar v4.0.0 - v6.7.5 - Peanut build 9 (virtualdisgrace.com):

 Copyright © 2015, 2016 Garvin Twine, Romka Swallowtail, Wendy Starfall
 Copyright © 2017, 2018 Garvin Twine, Wendy Starfall

 https://github.com/VirtualDisgrace/opencollar/commits/master
 https://github.com/WendyStarfall/opencollar/commits/master

--------------------------------------------------------------------------------

 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, see www.gnu.org/licenses/gpl-2.0

------------------------------------------------------------------------------*/

integer g_iBuild = 12;

string g_sSubMenu = "Size/Position";
string g_sParentMenu = "Settings";

list g_lMenuIDs;
integer g_iMenuStride = 3;

string POSMENU = "Position";
string ROTMENU = "Rotation";
string SIZEMENU = "Size";

float g_fSmallNudge=0.0005;
float g_fMediumNudge=0.005;
float g_fLargeNudge=0.05;
float g_fNudge=0.005;
float g_fRotNudge;

list SIZEMENU_BUTTONS = [ "-1%", "-2%", "-5%", "-10%", "+1%", "+2%", "+5%", "+10%", "100%" ];
list g_lSizeFactors = [-1, -2, -5, -10, 1, 2, 5, 10, -1000];
list g_lPrimStartSizes;
integer g_iScaleFactor = 100;
integer g_iSizedByScript;

integer CMD_OWNER = 500;
integer CMD_WEARER = 503;

integer NOTIFY = 1002;
integer REBOOT = -1000;
integer LINK_DIALOG = 3;
integer MENUNAME_REQUEST = 3000;
integer MENUNAME_RESPONSE = 3001;
integer MENUNAME_REMOVE = 3003;

integer DIALOG = -9000;
integer DIALOG_RESPONSE = -9001;
integer DIALOG_TIMEOUT = -9002;
integer BUILD_REQUEST = 17760501;

string UPMENU = "BACK";

key g_kWearer;

Dialog(key kRCPT, string sPrompt, list lChoices, list lUtilityButtons, integer iPage, integer iAuth, string sMenuType) {
    key kMenuID = llGenerateKey();
    llMessageLinked(LINK_DIALOG, DIALOG, (string)kRCPT + "|" + sPrompt + "|" + (string)iPage + "|" + llDumpList2String(lChoices, "`") + "|" + llDumpList2String(lUtilityButtons, "`") + "|" + (string)iAuth, kMenuID);
    integer iIndex = llListFindList(g_lMenuIDs, [kRCPT]);
    if (~iIndex) g_lMenuIDs = llListReplaceList(g_lMenuIDs, [kRCPT, kMenuID, sMenuType], iIndex, iIndex + g_iMenuStride - 1);
    else g_lMenuIDs += [kRCPT, kMenuID, sMenuType];
}

integer MinMaxUnscaled(vector vSize, float fScale) {
    if (fScale < 1.0) {
        if (vSize.x <= 0.01) return TRUE;
        if (vSize.y <= 0.01) return TRUE;
        if (vSize.z <= 0.01) return TRUE;
    } else {
        if (vSize.x >= 10.0) return TRUE;
        if (vSize.y >= 10.0) return TRUE;
        if (vSize.z >= 10.0) return TRUE;
    }
    return FALSE;
}

integer MinMaxScaled(vector vSize, float fScale) {
    if (fScale < 1.0) {
        if (vSize.x < 0.01) return TRUE;
        if (vSize.y < 0.01) return TRUE;
        if (vSize.z < 0.01) return TRUE;
    } else {
        if (vSize.x > 10.0) return TRUE;
        if (vSize.y > 10.0) return TRUE;
        if (vSize.z > 10.0) return TRUE;
    }
    return FALSE;
}

Store_StartScaleLoop() {
    g_lPrimStartSizes = [];
    integer iPrimIndex;
    vector vPrimScale;
    vector vPrimPosit;
    list lPrimParams;
    if (llGetNumberOfPrims()<2) {
        vPrimScale = llGetScale();
        g_lPrimStartSizes += vPrimScale.x;
    } else {
        for (iPrimIndex = 1; iPrimIndex <= llGetNumberOfPrims(); iPrimIndex++ ) {
            lPrimParams = llGetLinkPrimitiveParams( iPrimIndex, [PRIM_SIZE, PRIM_POSITION]);
            vPrimScale=llList2Vector(lPrimParams,0);
            vPrimPosit=(llList2Vector(lPrimParams,1)-llGetRootPosition())/llGetRootRotation();
            g_lPrimStartSizes += [vPrimScale,vPrimPosit];
        }
    }
    g_iScaleFactor = 100;
}

ScalePrimLoop(integer iScale, integer iRezSize, key kAV) {
    integer iPrimIndex;
    float fScale = iScale / 100.0;
    list lPrimParams;
    vector vPrimScale;
    vector vPrimPos;
    vector vSize;
    if (llGetNumberOfPrims()<2) {
        vSize = llList2Vector(g_lPrimStartSizes,0);
        if (MinMaxUnscaled(llGetScale(), fScale) || !iRezSize) {
            llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"The object cannot be scaled as you requested; prims are already at minimum or maximum size.",kAV);
            return;
        } else if (MinMaxScaled(fScale * vSize, fScale) || !iRezSize) {
            llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"The object cannot be scaled as you requested; prims would surpass minimum or maximum size.",kAV);
            return;
        } else llSetScale(fScale * vSize);
    } else {
        if  (!iRezSize) {
            for (iPrimIndex = 1; iPrimIndex <= llGetNumberOfPrims(); iPrimIndex++ ) {
                lPrimParams = llGetLinkPrimitiveParams( iPrimIndex, [PRIM_SIZE, PRIM_POSITION]);
                vPrimScale = llList2Vector(g_lPrimStartSizes, (iPrimIndex  - 1)*2);

                if (MinMaxUnscaled(llList2Vector(lPrimParams,0), fScale)) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"The object cannot be scaled as you requested; prims are already at minimum or maximum size.",kAV);
                    return;
                } else if (MinMaxScaled(fScale * vPrimScale, fScale)) {
                    llMessageLinked(LINK_DIALOG,NOTIFY,"1"+ "The object cannot be scaled as you requested; prims would surpass minimum or maximum size.",kAV);
                    return;
                }
            }
        }
        llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Scaling started, please wait ...",kAV);
        g_iSizedByScript = TRUE;
        for (iPrimIndex = 1; iPrimIndex <= llGetNumberOfPrims(); iPrimIndex++ ) {
            vPrimScale = fScale * llList2Vector(g_lPrimStartSizes, (iPrimIndex - 1)*2);
            vPrimPos = fScale * llList2Vector(g_lPrimStartSizes, (iPrimIndex - 1)*2+1);
            if (iPrimIndex == 1)
                llSetLinkPrimitiveParamsFast(iPrimIndex, [PRIM_SIZE, vPrimScale]);
            else
                llSetLinkPrimitiveParamsFast(iPrimIndex, [PRIM_SIZE, vPrimScale, PRIM_POSITION, vPrimPos]);
        }
        g_iScaleFactor = iScale;
        g_iSizedByScript = TRUE;
        llMessageLinked(LINK_DIALOG,NOTIFY,"1"+"Scaling finished, the %DEVICETYPE% is now on "+ (string)g_iScaleFactor +"% of the rez size.",kAV);
    }
}

ForceUpdate() {
    llSetText(".", <1,1,1>, 1.0);
    llSetText("", <1,1,1>, 1.0);
}

vector ConvertPos(vector pos) {
    integer ATTACH = llGetAttached();
    vector out ;
    if (ATTACH == 1) { out.x = -pos.y; out.y = pos.z; out.z = pos.x; }
    else if (ATTACH == 9) { out.x = -pos.y; out.y = -pos.z; out.z = -pos.x; }
    else if (ATTACH == 39) { out.x = pos.x; out.y = -pos.y; out.z = pos.z; }
    else if (ATTACH == 5 || ATTACH == 20 || ATTACH == 21 ) { out.x = pos.x; out.y = -pos.z; out.z = pos.y ; }
    else if (ATTACH == 6 || ATTACH == 18 || ATTACH == 19 ) { out.x = pos.x; out.y = pos.z; out.z = -pos.y; }
    else out = pos ;
    return out ;
}

AdjustPos(vector vDelta) {
    if (llGetAttached()) llSetPos(llGetLocalPos() + ConvertPos(vDelta));
    ForceUpdate();
}

vector ConvertRot(vector rot) {
    integer ATTACH = llGetAttached();
    vector out ;
    if (ATTACH == 1) { out.x = -rot.y; out.y = -rot.z; out.z = -rot.x; }
    else if (ATTACH == 9) { out.x = -rot.y; out.y = rot.z; out.z = rot.x; }
    else if (ATTACH == 39) { out.x = -rot.x; out.y = -rot.y; out.z = -rot.z; }
    else if (ATTACH == 5 || ATTACH == 20 || ATTACH == 21) { out.x = rot.x; out.y = -rot.z; out.z = rot.y; }
    else if (ATTACH == 6 || ATTACH == 18 || ATTACH == 19) { out.x = rot.x; out.y = rot.z; out.z = -rot.y; }
    else out = rot ;
    return out ;
}

AdjustRot(vector vDelta) {
    if (llGetAttached()) llSetLocalRot(llGetLocalRot() * llEuler2Rot(ConvertRot(vDelta)));
    ForceUpdate();
}

RotMenu(key kAv, integer iAuth) {
    string sPrompt = "\nHere you can tilt and rotate the %DEVICETYPE%.";
    list lMyButtons = ["tilt up ↻", "left ↶", "tilt left ↙", "tilt down ↺", "right ↷", "tilt right ↘"];// ria change
    Dialog(kAv, sPrompt, lMyButtons, [UPMENU], 0, iAuth,ROTMENU);
}

PosMenu(key kAv, integer iAuth) {
    string sPrompt = "\nHere you can nudge the %DEVICETYPE% in place.\n\nCurrent nudge strength is: ";
    list lMyButtons = ["left ←", "up ↑", "forward ↳", "right →", "down ↓", "backward ↲"];
    if (g_fNudge!=g_fSmallNudge) lMyButtons+=["▁"];
    else sPrompt += "▁";
    if (g_fNudge!=g_fMediumNudge) lMyButtons+=["▁ ▂"];
    else sPrompt += "▁ ▂";
    if (g_fNudge!=g_fLargeNudge) lMyButtons+=["▁ ▂ ▃"];
    else sPrompt += "▁ ▂ ▃";
    Dialog(kAv, sPrompt, lMyButtons, [UPMENU], 0, iAuth,POSMENU);
}

SizeMenu(key kAv, integer iAuth) {
    string sPrompt = "\nNumbers are based on the original size of the %DEVICETYPE%.\n\nCurrent size: " + (string)g_iScaleFactor + "%";
    Dialog(kAv, sPrompt, SIZEMENU_BUTTONS, [UPMENU], 0, iAuth,SIZEMENU);
}

DoMenu(key kAv, integer iAuth) {
    list lMyButtons ;
    string sPrompt;
    sPrompt = "\nChange the position, rotation and size of your %DEVICETYPE%.\n\nwww.opencollar.at/appearance";
    lMyButtons = [POSMENU, ROTMENU, SIZEMENU];
    Dialog(kAv, sPrompt, lMyButtons, [UPMENU], 0, iAuth,g_sSubMenu);
}

UserCommand(integer iAuth, string sStr, key kID) {
    sStr = llToLower(sStr);
    if (sStr == "menu "+llToLower(g_sSubMenu)) {
        if (kID != g_kWearer && iAuth != CMD_OWNER) {
            llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
            llMessageLinked(LINK_SET, iAuth, "menu " + g_sParentMenu, kID);
        } else DoMenu(kID, iAuth);
    } else if (sStr == "appearance") {
        if (kID!=g_kWearer && iAuth!=CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        else DoMenu(kID, iAuth);
    } else if (sStr == "rotation") {
        if (kID!=g_kWearer && iAuth!=CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        else RotMenu(kID, iAuth);
    } else if (sStr == "position") {
        if (kID!=g_kWearer && iAuth!=CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        else PosMenu(kID, iAuth);
    } else if (sStr == "size") {
        if (kID!=g_kWearer && iAuth!=CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        else SizeMenu(kID, iAuth);
    } else if (sStr == "rm resizer") {
        if (kID!=g_kWearer && iAuth!=CMD_OWNER) llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"%NOACCESS%",kID);
        else Dialog(kID, "\nDo you really want to remove the Resizer?", ["Yes","No","Cancel"], [], 0, iAuth,"rmresizer");
    }
}

default {
    on_rez(integer iParam) {
        llResetScript();
    }

    state_entry() {
        g_kWearer = llGetOwner();
        g_fRotNudge = PI / 32.0;
        Store_StartScaleLoop();
    }

    link_message(integer iSender, integer iNum, string sStr, key kID) {
        if (iNum == MENUNAME_REQUEST && sStr == g_sParentMenu)
            llMessageLinked(iSender, MENUNAME_RESPONSE, g_sParentMenu + "|" + g_sSubMenu, "");
        else if (iNum >= CMD_OWNER && iNum <= CMD_WEARER)
            UserCommand( iNum, sStr, kID);
        else if (iNum == DIALOG_RESPONSE) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            if (iMenuIndex != -1) {
                list lMenuParams = llParseString2List(sStr, ["|"], []);
                key kAv = (key)llList2String(lMenuParams, 0);
                string sMessage = llList2String(lMenuParams, 1);
                integer iAuth = (integer)llList2String(lMenuParams, 3);
                string sMenuType = llList2String(g_lMenuIDs, iMenuIndex + 1);
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);
                if (sMenuType == g_sSubMenu) {
                    if (sMessage == UPMENU) llMessageLinked(LINK_ROOT, iAuth, "menu " + g_sParentMenu, kAv);
                    else if (sMessage == POSMENU) PosMenu(kAv, iAuth);
                    else if (sMessage == ROTMENU) RotMenu(kAv, iAuth);
                    else if (sMessage == SIZEMENU) SizeMenu(kAv, iAuth);
                } else if (sMenuType == POSMENU) {
                    if (sMessage == UPMENU) {
                        llMessageLinked(LINK_ROOT, iAuth, "menu " + g_sParentMenu, kAv);
                        return;
                    } else if (llGetAttached()) {
                        if (sMessage == "forward ↳") AdjustPos(<g_fNudge, 0, 0>);
                        else if (sMessage == "left ←") AdjustPos(<0, g_fNudge, 0>);
                        else if (sMessage == "up ↑") AdjustPos(<0, 0, g_fNudge>);
                        else if (sMessage == "backward ↲") AdjustPos(<-g_fNudge, 0, 0>);
                        else if (sMessage == "right →") AdjustPos(<0, -g_fNudge, 0>);
                        else if (sMessage == "down ↓") AdjustPos(<0, 0, -g_fNudge>);
                        else if (sMessage == "▁") g_fNudge=g_fSmallNudge;
                        else if (sMessage == "▁ ▂") g_fNudge=g_fMediumNudge;
                        else if (sMessage == "▁ ▂ ▃") g_fNudge=g_fLargeNudge;
                    } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Sorry, position can only be adjusted while worn",kID);
                    PosMenu(kAv, iAuth);
                } else if (sMenuType == ROTMENU) {
                    if (sMessage == UPMENU) {
                        llMessageLinked(LINK_ROOT, iAuth, "menu " + g_sParentMenu, kAv);
                        return;
                    } else if (llGetAttached()) {
                        if (sMessage == "tilt right ↘") AdjustRot(<g_fRotNudge, 0, 0>);
                        else if (sMessage == "tilt up ↻") AdjustRot(<0, g_fRotNudge, 0>);
                        else if (sMessage == "left ↶") AdjustRot(<0, 0, g_fRotNudge>);
                        else if (sMessage == "right ↷") AdjustRot(<0, 0, -g_fRotNudge>);
                        else if (sMessage == "tilt left ↙") AdjustRot(<-g_fRotNudge, 0, 0>);
                        else if (sMessage == "tilt down ↺") AdjustRot(<0, -g_fRotNudge, 0>);
                    } else llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Sorry, position can only be adjusted while worn",kID);
                    RotMenu(kAv, iAuth);
                } else if (sMenuType == SIZEMENU) {
                    if (sMessage == UPMENU) {
                        llMessageLinked(LINK_ROOT, iAuth, "menu " + g_sParentMenu, kAv);
                        return;
                    } else {
                        integer iMenuCommand = llListFindList(SIZEMENU_BUTTONS, [sMessage]);
                        if (iMenuCommand != -1) {
                            integer iSizeFactor = llList2Integer(g_lSizeFactors, iMenuCommand);
                            if (iSizeFactor == -1000) {
                                if (g_iScaleFactor == 100)
                                    llMessageLinked(LINK_DIALOG,NOTIFY,"0"+"Resizing canceled; the %DEVICETYPE% is already at original size.",kID);
                                else ScalePrimLoop(100, TRUE, kAv);
                            }
                            else ScalePrimLoop(g_iScaleFactor + iSizeFactor, FALSE, kAv);
                        }
                        SizeMenu(kAv, iAuth);
                    }
                } else if (sMenuType == "rmresizer") {
                    if (sMessage == "Yes") {
                        llMessageLinked(LINK_ROOT, MENUNAME_REMOVE , g_sParentMenu + "|" + g_sSubMenu, "");
                        llMessageLinked(LINK_DIALOG,NOTIFY, "1"+"Resizer has been removed.", kAv);
                        if (llGetInventoryType(llGetScriptName()) == INVENTORY_SCRIPT) llRemoveInventory(llGetScriptName());
                    } else llMessageLinked(LINK_DIALOG,NOTIFY, "0"+"Resizer remains installed.", kAv);
                }
            }
        }
        else if (iNum == DIALOG_TIMEOUT) {
            integer iMenuIndex = llListFindList(g_lMenuIDs, [kID]);
            if (iMenuIndex != -1)
                g_lMenuIDs = llDeleteSubList(g_lMenuIDs, iMenuIndex - 1, iMenuIndex - 2 + g_iMenuStride);
        } else if (iNum == BUILD_REQUEST)
            llMessageLinked(iSender,iNum+g_iBuild,llGetScriptName(),"");
        else if (iNum == REBOOT && sStr == "reboot") llResetScript();
    }

    timer() {
        llSetTimerEvent(0);
        if (g_iSizedByScript) g_iSizedByScript = FALSE;
    }

    changed(integer iChange) {
        if (iChange & (CHANGED_SCALE)) {
            if (g_iSizedByScript) llSetTimerEvent(0.5);
            else Store_StartScaleLoop();
        }
        if (iChange & (CHANGED_SHAPE | CHANGED_LINK)) Store_StartScaleLoop();
    }
 }
