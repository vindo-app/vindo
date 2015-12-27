---
type: post
author: "Theodore"
published: true
---

I'm working on a UI redesign that will significantly improve the usability of Vindo. It'll do this primarily by putting the Start menu in the UI, in the form of a popup on the status bar icon. I'll also add some tooltips/explanatory text to make the UI self-explanatory.

The first thing you'll notice in the new design is that the menu in the status bar has been replaced with a popover. This is because the main thing you're going to see when you click on the icon is the start menu, and, even though you might think so, I'm not going to make it an actual menu. It'll be a nice colorful grid of buttons, like Launchpad, and you can can click on one of them to launch the program. You can also drag them to your Dock.

Having the start menu easily accessible is a big usability plus, because without it, the only way to run anything is to open Winefile, dig around the filesystem to find the program you want to run, and double-click it. Totally unusable. With the start menu, you can just click on the program you want to run, and it runs.

I'm also planning to put in some explanatory information:

  - When you run Vindo for the first time, it'll have a little popup pointing to the icon indicating you're supposed to click on it. This is not very obvious, although it seems obvious if you've been using Vindo for a while.
  - When you click the icon, it informs you that Vindo is initializing, and requests that you please wait.
  - In order to make it clear that you can drag the programs into your Dock, there'll be a little "Hint: You can drag these to your Dock." Also not too obvious.
  
I'm working on this right now. Here's a little sneak peek:

![setting up][setup]
  
  [setup]: /images/setting-up.png
  