#let examify(
  paper-size: "a4",
  font: "Noto Sans CJK SC",
  language: "zh",
  institute: none,
  author: none,
  doi: none,
  contact-link: none,
  contact-text: none,
  exam-name: none,
  subject-label: none,
  subject: none,
  marks: none,
  class: none,
  time: none,
  show-ans: false,
  content,
) = {

  // Document metadata
  set document(
    title: [#subject - #class],
    author: author,
    date: auto,
  )

  // Page setup
  set page(
    paper: paper-size,
    footer: context [
      #line(length: 100%)
      #grid(
        columns: (1fr, 1fr, 1fr),
        align: (left, center, right),
        if doi != none {
          doi
        } else {
          author
        },
        if contact-link != none {
          show link: underline
          link(contact-link, contact-text)
        },
        counter(page).display(
          "I/I",
          both: true,
        ),
      )
    ],
  )

  // Numbered list style
  set enum(numbering: "1.A.", body-indent: 1.3em)

  // Text settings
  set text(
    font: font,
    size: 12pt,
    lang: language,
  )

  // Paragraph settings
  set par(justify: true)

  // Heading
  let heading-number(.. index) = if index.pos().len() == 1 {
    "第" + numbering("一", index.at(0)) + "部分"
  } else if index.pos().len() == 2 {
    "第" + numbering("一", index.at(1)) + "节"
  } else {
    "错误：无法编号"
  }
  set heading(numbering: heading-number)

  // Institute name
  if institute != none {
    grid(
      columns: 1fr,
      align: (center),
      text(weight: "extrabold", size: 20pt, [#sym.angle.l.double #institute #sym.angle.r.double]),
    )
  }

  // Exam name
  if exam-name != none {
    grid(
      columns: 1fr,
      align: (center),
      text(weight: "bold", size: 15pt, exam-name),
    )
  }

  // Subject
  grid(
    columns: 1fr,
    align: (center),
    text(weight: "bold", {
      if subject-label != none {
        [#subject-label：]
      }
      [#subject]
    }),
  )

  // Marks, Class & Time
  grid(
    columns: (1fr, 1fr, 1fr),
    rows: (1.5em, 1.5em),
    align(left)[
      #text(weight: "bold", [总分：#marks])
    ],
    align(center)[
      #text(weight: "bold", [试卷类型：#class])
    ],
    align(right)[
      #text(weight: "bold", [考试时间：#time])
    ],
    align(left)[
      #text(weight: "bold", [命题人：#author])
    ],
    none,
    align(right)[
      #text(weight: "bold", [审题人：#author])
    ],
  )
  line(length: 100%)

  // Main content
  set align(left)
  set par(first-line-indent: (amount: 2em, all: true))
  content
}

#let secret = [绝密 #sym.star.filled 启用前]

#let exam-tips(content) = box[
  #text(weight: "bold", [注意事项]) \
  #content
]

#let ans(disp: false, answer) = if disp {
  [（#h(0.5em)#answer#h(0.5em)）]
} else {
  [（#h(2em)）]
}

#let why(disp: false, content) = if disp {
  [（#text(weight: "medium", [解析：])#content）]
}

#let writing-area(lines: 10, content) = for value in range(lines) {
  box(width: 100%, height: 1em, stroke: (bottom: 0.75pt), if value == 0 {
    content
  } else {
    none
  })
}
