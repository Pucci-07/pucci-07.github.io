---
layout: page
permalink: /writeups/
title: write-ups
nav: true
nav_order: 2
description: Cybersecurity write-ups, grouped by platform and target.
---

<div class="projects writeups-page">
  <p class="writeups-intro">Field notes from Hack The Box, Hackviser and hands-on security labs. Choose English or French on each target card.</p>

{% assign writeup_posts = site.posts | where_exp: "post", "post.writeup_id != nil" %}
{% assign platforms = writeup_posts | group_by_exp: "post", "post.writeup_platform" | sort_natural: "name" %}

{% for platform in platforms %}
{% assign platform_id = platform.name | slugify %}
<a id="{{ platform_id }}" href="#{{ platform_id }}">

<h2 class="category">{{ platform.name }}</h2>
</a>

{% assign machines = platform.items | group_by_exp: "post", "post.writeup_id" | sort_natural: "name" %}

  <div class="row row-cols-1 row-cols-md-3">
    {% for machine in machines %}
      {% assign machine_post = machine.items | first %}
      {% assign english_posts = machine.items | where: "writeup_language", "en" %}
      {% assign french_posts = machine.items | where: "writeup_language", "fr" %}
      <div class="col mb-4">
        <article class="writeup-card">
          <div class="writeup-card__image">
            <img src="{{ machine_post.writeup_image | relative_url }}" alt="{{ machine_post.title | escape }}" loading="lazy">
            <div class="writeup-card__fallback" aria-hidden="true">&gt; TARGET: {{ machine_post.title | escape }}</div>
          </div>
          <div class="writeup-card__body">
            <p class="writeup-card__meta">{% if machine_post.writeup_difficulty %}{{ machine_post.writeup_difficulty }}{% else %}{{ machine_post.writeup_platform }}{% endif %}</p>
            <h3>{{ machine_post.writeup_title | default: machine_post.title | escape }}</h3>
            <p>{{ machine_post.description | escape }}</p>
            <div class="writeup-card__links">
              {% for post in english_posts %}
                <a class="writeup-language-link" href="{{ post.url | relative_url }}" lang="en" aria-label="Read {{ machine_post.writeup_title | default: machine_post.title | escape }} in English">EN</a>
              {% endfor %}
              {% for post in french_posts %}
                <a class="writeup-language-link writeup-language-link--fr" href="{{ post.url | relative_url }}" lang="fr" aria-label="Lire {{ machine_post.writeup_title | default: machine_post.title | escape }} en français">FR</a>
              {% endfor %}
            </div>
          </div>
        </article>
      </div>
    {% endfor %}
  </div>
{% endfor %}
</div>

<script src="{{ '/assets/js/writeups.js' | relative_url }}" defer></script>
