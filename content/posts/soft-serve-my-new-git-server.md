+++
date = '2025-10-30T21:56:43+01:00'
draft = false
title = 'Soft Serve: My New Git Server'
+++

Looking for a cool terminal based GitHub alternative,
which is open-source, completely self-hosted and
doesn't use your code as training data?

[Soft Serve](https://github.com/charmbracelet/soft-serve) is the answer for you!

You can check out my instance here:

```bash
ssh -p 23231 git.nich.dk
```

I am currently only hosting my Linux .dotfiles
(it's a hidden repo, you can't see it),
and the source for the website that you're
visiting right now.

I'm planning on migrating all of my private
repositories from GitHub.

To make my life easier, I have added the following
to my SSH config file (~/.ssh/config):

```
Host soft
  HostName git.nich.dk
  Port 23231
```

So I can access my server easily by just typing
`ssh soft`

Here are some screenshots:

![Screenshot](/soft-serve/1.png)

![Screenshot](/soft-serve/2.png)

![Screenshot](/soft-serve/3.png)

![Screenshot](/soft-serve/4.png)
