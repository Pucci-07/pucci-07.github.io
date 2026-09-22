---
layout: course
title: SQL Injection & Database Enumeration
description: A hands-on course on identifying and exploiting SQL injection vulnerabilities, with a focus on systematic database enumeration across MySQL, PostgreSQL, MSSQL, Oracle, and SQLite.
instructor: DoOm
year: 2026
term: Fall
location: IPNET Cyber Club, Room TBD
time: Tuesdays and Thursdays, 4:00-5:30 PM
course_id: sql-injection-enumeration
schedule:
- week: 1
  date: Sep 30
  topic: Introduction to SQL Injection
  description: What SQL injection is, why it happens, and an overview of the different exploitation families (in-band, error-based, blind, out-of-band).
  materials:
  - name: Syllabus
    url: /assets/pdf/example_pdf.pdf
  - name: Slides
    url: /assets/pdf/example_pdf.pdf

- week: 2
  date: Oct 7
  topic: Fingerprinting the DBMS
  description: Identifying the underlying database engine before enumerating — version functions, differentiating error behavior, and comment syntax quirks across MySQL, PostgreSQL, MSSQL, and Oracle.
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Lab — Fingerprinting Challenge
    url: /assets/pdf/example_pdf.pdf

- week: 3
  date: Oct 14
  topic: information_schema and System Catalogs
  description: Understanding information_schema as a virtual metadata database, and its per-engine equivalents (pg_catalog, sys.*, all_/user_/dba_* in Oracle, sqlite_master).
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Cheatsheet — System Tables by DBMS
    url: /assets/pdf/example_pdf.pdf

- week: 4
  date: Oct 21
  topic: UNION-Based Extraction
  description: Determining column count with ORDER BY, locating displayable columns, and extracting concatenated data with GROUP_CONCAT, STRING_AGG, and LISTAGG.
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Assignment 1 — UNION Lab
    url: /assets/pdf/example_pdf.pdf

- week: 5
  date: Oct 28
  topic: Error-Based Extraction
  description: Forcing the database to leak data through crafted error messages — EXTRACTVALUE, UPDATEXML, CAST/CONVERT tricks, and Oracle-specific error functions.
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Coding Lab
    url: https://github.com/

- week: 6
  date: Nov 4
  topic: Blind SQL Injection
  description: Boolean-based and time-based blind techniques for extracting data with no visible output — building extraction scripts around SUBSTRING and conditional delays.
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Assignment 2 — Blind Extraction Script
    url: /assets/pdf/example_pdf.pdf

- week: 7
  date: Nov 11
  topic: File Read/Write and RCE Paths
  description: Escalating a SQL injection into file disclosure or remote code execution — LOAD_FILE/INTO OUTFILE, xp_cmdshell, COPY ... TO PROGRAM, and Oracle Java stored procedures.
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Review Materials
    url: /assets/pdf/example_pdf.pdf

- week: 8
  date: Nov 18
  topic: Filter Bypasses and Automation
  description: Common WAF/filter evasion techniques (encoding, inline comments, case mixing) and automating the full workflow with sqlmap.
  materials:
  - name: Lecture Notes
    url: /assets/pdf/example_pdf.pdf
  - name: Final Assignment — Full Chain CTF
    url: /assets/pdf/example_pdf.pdf
---

## Course Overview

This course provides a systematic, engine-by-engine approach to SQL injection and database enumeration. Students will:

- Learn to fingerprint a DBMS before attempting enumeration, avoiding wasted effort on queries that don't apply
- Master the three-tier enumeration hierarchy (databases → tables → columns → data) across MySQL, PostgreSQL, MSSQL, Oracle, and SQLite
- Practice UNION-based, error-based, and blind (boolean/time) extraction techniques
- Understand when a SQL injection can escalate into file read/write or remote code execution
- Get hands-on with filter bypass techniques and automation via sqlmap

All exercises are conducted in authorized lab environments (CTF platforms or dedicated vulnerable VMs) only.

## Prerequisites

- Basic SQL knowledge (SELECT, WHERE, JOIN)
- Familiarity with HTTP requests and web application basics
- Comfort with a Linux command line

## Textbooks & References

- "The Web Application Hacker's Handbook" by Dafydd Stuttard & Marcus Pinto
- OWASP Testing Guide — SQL Injection chapter
- sqlmap official documentation

## Grading

- Assignments: 50%
- Final CTF-style project: 40%
- Participation: 10%
