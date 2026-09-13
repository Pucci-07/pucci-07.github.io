---
layout: page
title: Honeypot project
description: with background image
img: assets/img/wallhaven-mpyxm1.png
importance: 1
category: work
related_publications: true
---

# Building an AI-Powered Honeypot: The Story of a Project That Never Went as Planned

When we started this project, the initial idea fit in one sentence: deploy a honeypot infrastructure capable of luring attackers, logging their actions, with AI making the whole thing feel more realistic. Simple on paper. In practice, the architecture changed shape several times, ran straight into the limits of our infrastructure, and ended with the capture of a real attacker session. Here's the road we took.

## The Starting Point: Lure, Observe, Learn

A honeypot is a target you deliberately expose to attackers so you can watch what they do, without ever putting a real system at risk. The goal is easy to explain and much harder to pull off well: the target has to feel real enough that an attacker actually sticks around.

Most classic tools in this space emulate services in a fairly rigid way. We wanted something more realistic — and more than that, we wanted the system's behavior to adapt to whatever application it was imitating, instead of always giving the same generic response. That requirement pushed us toward a more ambitious idea: instead of faking it, why not run real applications inside a controlled environment, with a system able to pull activity traces regardless of which application was running?

## First Pivot: Thinking Like One Real Machine, Not a Set of Isolated Services

Our first architecture kept every service in its own separate environment. It didn't take long to realize that an attacker exploring a compromised machine doesn't see a bunch of isolated services on different addresses — they see one machine with several entry points. So we brought the different services (web access, file transfer, database, remote login) together into a single coherent environment, closer to a real machine than a collection of disconnected pieces.

For remote login specifically, we wanted to avoid any kind of simulation: the system only acts as a bridge to the real environment, never faking a terminal.

## Hitting the Infrastructure Wall

For isolation, we were aiming for a solution robust at the hardware level — something far more airtight than a plain containerized environment. Digging into it, though, we discovered our hosting simply didn't support that level of virtualization. It's the kind of moment that reveals a hard truth: the ideal architecture on paper runs into the very real constraints of whatever infrastructure you actually have.

Rather than force it, we made a pragmatic call: go back to the architecture we'd already built and had working, and evolve the isolation gradually, step by step, instead of waiting for a perfect solution that only existed in theory.

## Picking a Simple First Target

To validate the whole pipeline end to end, we chose to start with a single application rather than several at once — one known for being deliberately vulnerable, easy to deploy, and with activity logs that were straightforward to work with.

This is where the small practical details took over — the kind no theoretical plan ever mentions. Missing system tools where we expected them, activity logs tucked away in unexpected places, log formats with undocumented edge cases. That kind of discovery, the kind you only get by actually doing the work, is exactly the knowledge you can't get any other way.

## Building the Collection Pipeline

Once we'd identified the activity traces, we needed to pull them, structure them, and store them in a usable way. We chose to write the collection script ourselves rather than delegate it, so we'd understand every step of the processing. That script runs continuously, feeding a database designed for analysis while keeping a raw backup in parallel — a database deliberately kept separate from the rest of the honeypot, so an attacker who managed to move laterally could never reach it.

Network isolation was its own focus area too: the target environment is cut off from any way of bouncing back out to the internet. Nothing should be able to leave the honeypot to go attack somewhere else.

## Extending the Infrastructure Without Giving Away the Truth

To expose the honeypot without revealing its real address, we set up a relay on a completely separate server, hosted elsewhere. That relay forwards traffic to the honeypot while preserving the attacker's real origin — without that precaution, every connection would have appeared to come from the relay, and the collected data would have lost all its value.

On the monitoring side, a centralized system rounded out the setup, making it far easier to explore events than digging through raw log files.

## The Moment of Truth

After all these adjustments — the architecture rethought, isolation revisited, the collection pipeline refined — the whole system finally ran stably. And then came the moment that gives a project like this its real meaning: the system captured a genuine session from a real attacker, complete with authentic commands being executed. This was no longer a local simulation — it was proof that the infrastructure was attracting and logging real malicious traffic from the outside world.

## What We Took Away From This Project

Beyond the technical side, this project mostly showed us how much a security system's architecture gets built through iteration, not from a plan set in stone from day one:

- **Available infrastructure dictates the choices, not the other way around.** A hardware limitation was enough to rule out the solution we were initially aiming for, however appealing it looked in theory. Knowing when to pivot to what's actually available, instead of digging in, is a skill in its own right.
- **Realism lives in the details.** It's the small rough edges — the ones you only find by actually doing the work — that separate a project that truly works from one that only works on paper.
- **Isolation has to be layered, not surface-level.** Every layer matters, because a poorly isolated honeypot stops being a honeypot and becomes a liability.
- **The ultimate validation is production.** No amount of local testing replaces the first real attacker session ever captured. That's the moment that confirms the architecture — however winding the path to get there — is finally doing its job.

This project is far from finished, but it captures a broader truth about working in cybersecurity: the best architectures rarely arrive fully formed from a spec sheet. They get built against real-world constraints, one pragmatic decision at a time.

