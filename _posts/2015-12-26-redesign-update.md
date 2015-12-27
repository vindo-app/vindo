---
type: post
author: Theodore
title: "Redesign Update: $&@#*@!%!"
published: true
---

Since I last posted here, I've made some progress on the redesign. When you install 7-Zip, this happens:

![7-zip in start menu][start]

But then this happens:

![file not found error messages][error1]

And then this happens:

![xcode error message][error2]

Both of these problems defy the laws of computing. The first one is a file copy that failed because the file doesn't exist, which can't be true because it's there when I check just before the copy. The second problem is my program being possessed by something that won't allow anything to debug it. This is the bigger problem.

I've [asked on Stack Overflow][so] why this is happening, but I haven't gotten an answer, even with a 100 reputation bounty. So I submitted a TSI (technical support incident) to Apple DTS (developer technical support), but they're closed for the holidays. I'll get a response in 2-3 weeks. During that time, I can't work on Vindo.

But when I get the problem fixed, I'll come back to Vindo, and keep working on the redesign. Maybe then someone will read this blog.

  [start]: /images/start-menu.png
  [error1]: /images/xcode_error.png
  [error2]: /images/error2.png
  [so]: http://stackoverflow.com/questions/34444051/lost-connection-to-my-mac-on-every-debugger-interaction