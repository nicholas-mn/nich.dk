+++
date = '2025-09-02T16:56:29+02:00'
draft = false
title = 'Low-Code / No-Code Development Sucks'
+++

While learning programming, I was very attracted to Low Code / No Code tools.

It allowed me, with my meager skills, to quickly get a working web app out.

I was convinced that developing things from scratch was a waste of time.

Tools like Appsmith, Budibase, Flutterflow etc. are clearly the future.
Anyone writing things from scratch in frameworks like Angular or React are clearly just wasting their time.

Why would actually code anything from scratch, when you can just drag and drop elements??

What a fool I was.

## It was great at first

I didn't want to just use any no/low-code tool.

It had to be open source and I shouldn't be stuck in some vendors ecosystem.

These 2 requirements put a quick stop in my journey.

Eventually I found [OpenNoodl](https://github.com/The-Low-Code-Foundation/opennoodl), which I had great fun using.

But it was abandoned by it's developers and kept on a lifeline by a single community member.

Clearly not sustainable.

Git integration also sucked (the uncompiled code is a web of JSON)

I ended up making a internal POC for the previous company I worked at with it.
I also used [n8n](https://n8n.io/) (another mistake) for server actions.

It worked great!
The POC was put directly in production.

It was my first development project actually going live, so I was ecstatic!

## Maintenance Hell

As I progressed with learning web development, I stumbled upon [Svelte](https://svelte.dev/).

It just made sense!

The syntax was clear and not convoluted like React/Angular.

It wrote like standard HTML, CSS and Javascript, so it felt very intuitive.

As of writing this, I have made many side projects with Svelte(Kit).

What?
We need a new feature for the POC (which is in prod)?

Sure, let me just open up OpenNoodl and n8n, and make some changes...

This was the start of my personal hell.

I have to work with _nodes_ to edit the frontend (OpenNoodl) and backend (n8n).

n8n is not version controlled in the Community Edition.

Any change might break the app and rolling back is not trivial.

It's actually not possible if you catch the bug after 24 hours.
In the n8n community version, it only saves old iterations of workflows up to a day.

Collaboration is impossible, as no sane developer wants to learn and use OpenNoodl

GitOps is also impossible, as OpenNoodl only exports the compiled code via their desktop app.

This means copying the compiled app files from your machine to the server.

## Just do it the right way

Don't be like me.

Learn proper (web) development and do it the right way.

By using any of these tools, you might be saving time in the short term.
But in the long term, you will hate your life.

You might even discover that the act of actually coding is very satisfying.

Don't even get me started on AI.

It's the ultimate footgun, when learning web development.

You will learn **much** less, if you let the AI code for you.

If you have to use, only ask it questions, like you would Google.

Don't delegate thinking to it. You will become dumber.
