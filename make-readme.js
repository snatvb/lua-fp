const fs = require('fs')
const path = require('path')

const script = path.resolve(__dirname, 'lib.lua')

const parseComments = (lines) => {
  let result = [] // Все блоки комментариев
  let buffer = [] // Буфер для сборки блока
  let level = 0 // Уровень вложенности

  const saveBuffer = () => {
    buffer.splice(0, 1) // Удаление первой строки (--[==[)
    result.push(buffer)
    buffer = []
  }

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i]
    // Начало комментария
    if (line.startsWith('--[==[')) {
      level++
    // Конец комментария
    } else if (line.startsWith(']==]')) {
      level--
      if (level === 0) { saveBuffer() }
    }

    // Если вложенность больше 0, значит идут
    // строки комментраиев, происходит запись в буфер
    if (level > 0) { buffer.push(line) }
  }

  return result
}

const blockToMarkdown = {
  name: (buffer) => {
    const name = buffer[0].replace(/[\s]*@name[\s]*/gi, '').trim()
    return `## ${name}`
  },
  sig: (buffer) => {
    const sig = buffer[0].replace(/[\s]*@sig[\s]*/gi, '').trim()
    return `###### *${sig}*`
  },
  desc: (buffer) => {
    const desc = buffer
      .slice(1)
      .map((line) => {
        const str = line.replace(/^([\s]*)/gi, '')
        return str.length > 0 ? str : '\n'
      })
      .join(' ')
    return `${desc}`
  },
  example: (buffer) => {
    const code = buffer
      .slice(1)
      .map((line) => line.replace(/^([\s]{2,2})/gi, ''))
      .join('\n')
    return `\`\`\`lua\n${code}\n\`\`\``
  },
}

const parseCommentBlock = (commentLines) => {
  let markdownLines = []
  let buffer = [] // Буфер для сборки блока

  const saveBuffer = () => {
    const type = buffer[0].match(/@([a-z0-9]+)/i)[1]
    const handler = blockToMarkdown[type]
    if (handler) {
      markdownLines.push(handler(buffer))
    } else {
      console.warn(`Unknown type comment @${type}`)
    }

    buffer = []
  }

  for (let i = 0; i < commentLines.length; i++) {
    const line = commentLines[i]
    const trimmed = line.trim()

    if(trimmed.startsWith('@') && buffer.length > 0) { saveBuffer() }
    buffer.push(line)
  }
  if (buffer.length > 0) { saveBuffer() }

  // console.log(markdownLines)

  return markdownLines
}

const parseCommentBlocks = (comments) => {
  let result = []
  for (let i = 0; i < comments.length; i++) {
    const commentLines = comments[i]
    result.push(parseCommentBlock(commentLines).join('\n\n'))
  }
  return result
}

const README_DESCRIPTION = `
  # Utrix Library for functional programming in lua

  Данная библотека призвана собрать в себе основные функции для функционального программирвоания на Lua

  ---
`

const start = () => {
  const body = fs.readFileSync(script, 'utf-8')
  const lines = body.replace(/\r/gi, '').split('\n')
  const comments = parseComments(lines)
  const readmeBlocks = parseCommentBlocks(comments)
  const markdown = README_DESCRIPTION + readmeBlocks.join('\n\n---\n\n')
  fs.writeFileSync(path.resolve(__dirname, 'README.md'), markdown, function(err) {
    if (err) {
      throw new Error(err)
    } else {
      console.info('Done!')
    }
  })
}

start()
