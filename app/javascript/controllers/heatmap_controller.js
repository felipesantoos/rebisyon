import { Controller } from "@hotwired/stimulus"

// Pure HTML/CSS calendar heatmap (GitHub-style)
export default class extends Controller {
  static values = {
    data: { type: String, default: "{}" }
  }

  connect() {
    this.render()
  }

  render() {
    let data = {}
    try {
      data = JSON.parse(this.dataValue)
    } catch {
      return
    }

    const today = new Date()
    const startDate = new Date(today)
    startDate.setDate(startDate.getDate() - 364)

    // Align to start of week (Sunday)
    startDate.setDate(startDate.getDate() - startDate.getDay())

    const maxVal = Math.max(1, ...Object.values(data))
    const weeks = []
    let currentDate = new Date(startDate)

    while (currentDate <= today) {
      const week = []
      for (let day = 0; day < 7; day++) {
        const dateStr = currentDate.toISOString().split("T")[0]
        const value = data[dateStr] || 0
        let level = 0
        if (value > 0) {
          const ratio = value / maxVal
          if (ratio <= 0.25) level = 1
          else if (ratio <= 0.5) level = 2
          else if (ratio <= 0.75) level = 3
          else level = 4
        }

        week.push({
          date: dateStr,
          value: value,
          level: level,
          future: currentDate > today
        })
        currentDate.setDate(currentDate.getDate() + 1)
      }
      weeks.push(week)
    }

    // Build HTML
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    let html = '<div class="overflow-x-auto"><div class="inline-flex gap-0.5">'

    weeks.forEach((week) => {
      html += '<div class="flex flex-col gap-0.5">'
      week.forEach((day) => {
        if (day.future) {
          html += '<div class="w-3 h-3"></div>'
        } else {
          html += `<div class="w-3 h-3 heatmap-cell heatmap-${day.level}" title="${day.date}: ${day.value} reviews"></div>`
        }
      })
      html += '</div>'
    })

    html += '</div></div>'

    // Legend
    html += '<div class="flex items-center gap-2 mt-2 text-xs text-gray-500">'
    html += '<span>Less</span>'
    for (let i = 0; i <= 4; i++) {
      html += `<div class="w-3 h-3 heatmap-cell heatmap-${i}"></div>`
    }
    html += '<span>More</span></div>'

    this.element.innerHTML = html
  }
}
