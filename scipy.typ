#import "frontmatter.typ": orcidLogo

#let leftCaption(it) = {
  set text(size: 8pt)
  set align(left)
  set par(justify: true)
  text(weight: "bold")[#it.supplement #it.counter.display(it.numbering)]
  "."
  h(4pt)
  set text(fill: black.lighten(20%), style: "italic")
  it.body
}

#let template(
  // The paper's title.
  title: "Paper Title",
  subtitle: none,
  // An array of authors. For each author you can specify a name, orcid, and affiliations.
  // affiliations should be content, e.g. "1", which is shown in superscript and should match the affiliations list.
  // Everything but the name is optional.
  authors: (),
  // This is the affiliations list. Include an id and `name` in each affiliation. These are shown below the authors.
  affiliations: (),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // The short-title is shown in the running header
  short-title: none,
  // The short-citation is shown in the running header, if set to auto it will show the author(s) and the year in APA format.
  short-citation: auto,
  // A DOI link, shown in the header on the first page. Should be just the DOI, e.g. `10.10123/123456` ,not a URL
  doi: none,
  heading-numbering: "1.1.1",
  // Show an Open Access badge on the first page, and support open science, default is true, because that is what the default should be.
  open-access: true,
  // A list of keywords to display after the abstract
  keywords: (),
  // Date published, for example, when you publish your preprint to an archive server.
  // To hide the date, set this to `none`. You can also supply a list of dicts with `title` and `date`.
  date: datetime.today(),
  // Feel free to change this, the font applies to the whole document
  font-face: "Noto Sans",
  // A link to the github repository
  github: none,
  // The paper's content.
  body
) = {
  let theme = rgb("#2453A1")
  let paper-size = "us-letter"
  // The venue is show in the footer
  let venue = "SciPy 2023"
  let logo = [
    #image("logo.svg")
    #v(-13pt)
    #align(center)[
      #text(size: 15pt, style: "italic", weight: "bold", fill: theme)[SciPy 2023]
      #v(-6pt)
      #text(size: 10pt, style: "italic", weight: "light", fill: theme)[July 10 – July 16, 2023]
    ]
    #v(13pt)
    #set par(justify: true)
    #text(size: 7.5pt, fill: black.lighten(10%))[
      Proceedings of the 22#super[nd]\
      Python in Science Conference
    ]
    #text(size: 6pt, fill: black.lighten(40%))[
      ISSN: 2575-9752
    ]
  ]
  let spacer = text(fill: gray)[#h(8pt) | #h(8pt)]


  let dates;
  if (type(date) == "datetime") {
    dates = ((title: "Published", date: date),)
  } else if (type(date) == "dictionary") {
    dates = (date,)
  } else {
    dates = date
  }
  date = dates.at(0).date

  // Create a short-citation, e.g. Cockett et al.
  let year = if (date != none) { date.display("[year]") }
  if (short-citation == auto and authors.len() == 1) {
    short-citation = authors.at(0).name.split(" ").last()
  } else if (short-citation == auto and authors.len() == 2) {
    short-citation = authors.at(0).name.split(" ").last() + " & " + authors.at(1).name.split(" ").last()
  } else if (short-citation == auto and authors.len() > 2) {
    short-citation = authors.at(0).name.split(" ").last() + " " + emph("et al.")
  }

  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  show link: it => [#text(fill: theme)[#it]]
  show ref: it => {
    if (it.element == none)  {
      // This is a citation showing 2024a or [1]
      show regex("([\d]{1,4}[a-z]?)"): it => text(fill: theme, it)
      it
      return
    }
    // The rest of the references, like `Figure 1`
    set text(fill: theme)
    it
  }


  set page(
    paper-size,
    margin: (left: 25%),
    columns: 1,
    header: locate(loc => {
      if(loc.page() == 1) {
        let headers = (
          if (open-access) { smallcaps[Open Access] },
          if (doi != none) { link("https://doi.org/" + doi, "https://doi.org/" + doi)}
        )
        return align(left, [
          #set text(font: font-face, size: 8pt, fill: gray.darken(50%))
          #headers.filter(header => header != none).join(spacer)
        ])
      } else {

        let yearAndComma = if (year != none) {", " + year} else { "" }
        let running-title = if (short-title != none) {short-title} else { title }
        return align(right)[
          #set text(font: font-face, size: 8pt, fill: gray.darken(50%))
          #(
            running-title,
            short-citation + yearAndComma,
          ).filter(header => header != none).join(spacer)
        ]
      }
    }),
    footer: block(
      width: 100%,
      stroke: (top: 1pt + gray),
      inset: (top: 8pt, right: 2pt),
      [
        #set text(font: font-face, size: 9pt, fill: gray.darken(50%))
        #grid(columns: (75%, 25%),
          align(left,
            (
              if(venue != none) {emph(venue)},
              if(date != none) {date.display("[month repr:long] [day], [year]")}
            ).filter(t => t != none).join(spacer)
          ),
          align(right)[
            #counter(page).display() of #locate((loc) => {counter(page).final(loc).first()})
          ]
        )
      ]
    )
  )

  // Set the body font.
  set text(font: font-face, size: 10pt)
  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 1em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: heading-numbering)
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    set text(10pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement],[Acknowledgments], [Acknowledgements])
      // #set align(center)
      #set text(if is-ack { 10pt } else { 12pt })
      #show: smallcaps
      #v(20pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(13.75pt, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(style: "italic")
      #v(10pt, weak: true)
      #if it.numbering != none {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering(heading-numbering, ..levels)
        [. ]
      }
      _#(it.body):_
    ]
  })


  if (logo != none) {
    place(
      top,
      dx: -33%,
      float: false,
      box(
        width: 27%,
        {
          if (type(logo) == "content") {
            logo
          } else {
            image(logo, width: 100%)
          }
        },
      ),
    )
  }


  // Title and subtitle
  box(inset: (bottom: 2pt), text(17pt, weight: "bold", fill: theme, title))
  if subtitle != none {
    parbreak()
    box(text(14pt, fill: gray.darken(30%), subtitle))
  }
  // Authors and affiliations
  if authors.len() > 0 {
    box(inset: (y: 10pt), width: 100%, {
      authors.map(author => {
        text(11pt, weight: "semibold", author.name)
        h(1pt)
        if "affiliations" in author {
          super(author.affiliations)
        }
        if "orcid" in author {
          orcidLogo(orcid: author.orcid)
        }
      }).join(", ", last: ", and ")
    })
  }
  if affiliations.len() > 0 {
    box(inset: (bottom: 9pt), width: 100%, {
      set text(7pt, fill: gray.darken(50%))
      affiliations.map(affiliation => {
        super(affiliation.id)
        h(1pt)
        affiliation.name
      }).join(", ")
    })
  }

  let kind = none
  let corresponding = authors.filter((author) => "email" in author).at(0, default: none)
  let margin = (
    if corresponding != none {
      (
        title: "Correspondence to",
        content: [
          #corresponding.name\
          #link("mailto:" + corresponding.email)[#corresponding.email]
        ],
      )
    },
    (
      title: "Open Access",
      content: [
        #set par(justify: true)
        #set text(size: 7pt)
        Copyright © #{ year }
        #short-citation.
        This is an open-access article distributed under the terms of the
        #link("https://creativecommons.org/licenses/by/4.0/")[Creative Commons Attribution License],
        which permits unrestricted use, distribution, and reproduction in any medium, provided the original author and source are credited.
      ]
    ),
    if github != none {
      (
        title: "Data Availability",
        content: [
          Source code available:\
          #link(github, github)
        ],
      )
    },
  ).filter((m) => m != none)

  place(
    left + bottom,
    dx: -33%,
    dy: -10pt,
    box(width: 27%, {
      if (kind != none) {
        show par: set block(spacing: 0em)
        text(11pt, fill: theme, weight: "semibold", smallcaps(kind))
        parbreak()
      }
      if (dates != none) {
        let formatted-dates

        grid(columns: (40%, 60%), gutter: 7pt,
          ..dates.zip(range(dates.len())).map((formatted-dates) => {
            let d = formatted-dates.at(0);
            let i = formatted-dates.at(1);
            let weight = "light"
            if (i == 0) {
              weight = "bold"
            }
            return (
              text(size: 7pt, fill: theme, weight: weight, d.title),
              text(size: 7pt, d.date.display("[month repr:short] [day], [year]"))
            )
          }).flatten()
        )
      }
      v(2em)
      grid(columns: 1, gutter: 2em, ..margin.map(side => {
        text(size: 7pt, {
          if ("title" in side) {
            text(fill: theme, weight: "bold", side.title)
            [\ ]
          }
          set enum(indent: 0.1em, body-indent: 0.25em)
          set list(indent: 0.1em, body-indent: 0.25em)
          side.content
        })
      }))
    }),
  )


  let abstracts
  if (type(abstract) == "content") {
    abstracts = ((title: "Abstract", content: abstract),)
  } else {
    abstracts = abstract
  }

  box(inset: (top: 16pt, bottom: 16pt), stroke: (top: 1pt + gray, bottom: 1pt + gray), {

    abstracts.map(abs => {
      set par(justify: true)
      text(fill: theme, weight: "semibold", size: 9pt, abs.title)
      parbreak()
      text(size: 9pt, abs.content)
    }).join(parbreak())
  })
  if (keywords.len() > 0) {
    text(size: 9pt, {
      text(fill: theme, weight: "semibold", "Keywords")
      h(8pt)
      keywords.join(", ")
    })
  }
  v(10pt)

  show par: set block(spacing: 1.5em)

  show figure.caption: leftCaption
  set figure(placement: auto)

  // Display the paper's contents.
  body
}
