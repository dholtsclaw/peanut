##### These are extensions!

If you add any of these to your device, there are a few requirements that you need to be aware of:

* ``oc_couples.lsl`` requires specially crafted "couples animations". Unfortunately explaining the creation process of these would exceed the scope of this readme. In a nutshell, there has to be an animation for avatar A and avatar B, each animation has to be displaced slightly forwards, so the avatar's can reach one another for i.e. hugging each other beyond their physical bounding box. Then the animations have to noted in a configuration card, called ``.couples`` using this format ``
hug|~wearer-anim|~partner-anim|0.4|_SELF_ hugs _PARTNER_.`` one sequence per line. The couples extension, along with compatible animations and the configuration card have to live in the same link as the ``oc_anim.lsl`` program.

* ``oc_looks.lsl`` is a variation of ``oc_themes.lsl`` with the only difference of significance to offer a menu style that resembles more closely the one of the very old Appearance bundle style that OpenCollar versions prior to API 3.9 used to have. You can either use themes or looks, but not both programs at the same time.

* ``oc_resizer.lsl`` is a handy resizer utility that lives in the settings menu of the device. You can use it to resize large link-sets in a non-destructive way, and to adjust accessory remotely through authorized play partners.

* ``oc_rlvstuff.lsl`` is a RLV command controller that relies on ``oc_rlvsys.lsl``. It is a merge of the very old RLV bundle and quite possibly requires fixes left and right. Some users like it though because it allows them to set individual so-called RLV restrictions via menu buttons. This extension is only relevant to users who prefer button menus, the same can be achieved with the RLV terminal that can be opened on the standard device with ``<prefix> terminal``

* ``oc_themes.lsl`` can load visual themes for devices. This extension is commonly only used in our free selection of necklaces because it is difficult to configure and not very intuitive. Themes live in a configuration card called ``.themes`` and need to follow a format, such as i.e.:

```
[ ThemeName ]
ElementName~<texture_id>~<color_vector>~<shiny_type>~<glow_level>
Ring~89556747-24cb-43ed-920b-47caed15465f~<1,1,1>~none/low/medium/high/specular~none/low/medium/high/veryHigh
```

* ``oc_undress.lsl`` is an extension that relies on ``oc_rlvsys.lsl`` and can be used to detach and "strip" avatar attachments and baked on system "clothing". The premise of this feature can be very misleading nowadays as most avatars are really all attachment variants, composed of character-rigged 3D models. Although users who roll super old-school might still love this feature!

* ``oc_update.lsl`` is a small utility that communicates to Wendy's proprietary installer for managing updates. Not everyone will want their device to receive those updates, but those who do can feel free to add it to their device. As OpenCollar devices prior to version 6.7 were prone to malicious code injection, it is strongly advisable to distribute this script within Second Life® in a non-modifiable form, and with a discrete channel (should a custom installer device be used, such as the legacy OpenCollar Six installer.)
