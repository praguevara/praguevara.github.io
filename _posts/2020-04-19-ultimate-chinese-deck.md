---
layout: post
title: "Ultimate Chinese Deck"
date: 2020-02-27
---

After having stopped for almost a month with my Anki revisions (lmao, not even two months), and bored in isolation, I run into [ Loach JC, Wang J (2016) Optimizing the Learning Order of Chinese Characters Using a Novel Topological Sort Algorithm](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0163623), which is supposed to outperform previous algorithms, such as [Yan X, Fan Y, Di Z, Havlin S, Wu J (2013) Efficient Learning Strategy of Chinese Characters Based on Network Approach](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0069745), which is the one used in 3000 Hanzi to learn first, which I already wrote about in [my previous post](/blog/2020/02/27/learning-chinese).

So, being bored and as the procrastinator that I am (because I had tons of assignments to do), I decided to return to learning Chinese with a newer Anki deck.

After fighting for two days straight with Python's (nonexistent) type-system, you can access the fineshed result on my [GitHub repo](https://github.com/praguevara/UltimateChinese).

In the end, I used these resources to get there:

-  [The paper's data](https://journals.plos.org/plosone/article/file?type=supplementary&id=info:doi/10.1371/journal.pone.0163623.s001).
-  [CC-CEDICT](https://www.mdbg.net/chinese/dictionary?page=cc-cedict), the same dictionary used by the great app Pleco.
-  A [list of radicals](https://www.hackingchinese.com/kickstart-your-character-learning-with-the-100-most-common-radicals/) and their meanings that weren't included in CC-CEDICT.
- [Google's Wavenet](https://cloud.google.com/text-to-speech) for synthetizing audio.
- [pandas](https://pandas.pydata.org/), the excelent Python library for data manipulation.
- [genanki](https://github.com/kerrickstaley/genanki) for exporting the notes.

The deck probably has many bugs, and my CSS capabilities are pretty limited. I'd love to get your feedback if you leave it through the issues feature on the repository. I'd also gladly merge your pull requests.