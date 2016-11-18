export default class Board {
  constructor (state) {
    this.state = state
  }

  onClick(callback) {
    this.onClick = callback
  }

  draw (domElement) {
    domElement.innerHTML = `
    <ul>
      <li data-x='0' data-y='0'><span>${this.state[0][0] || ''}</span></li>
      <li data-x='0' data-y='1'><span>${this.state[0][1] || ''}</span></li>
      <li data-x='0' data-y='2'><span>${this.state[0][2] || ''}</span></li>
      <li data-x='1' data-y='0'><span>${this.state[1][0] || ''}</span></li>
      <li data-x='1' data-y='1'><span>${this.state[1][1] || ''}</span></li>
      <li data-x='1' data-y='2'><span>${this.state[1][2] || ''}</span></li>
      <li data-x='2' data-y='0'><span>${this.state[2][0] || ''}</span></li>
      <li data-x='2' data-y='1'><span>${this.state[2][1] || ''}</span></li>
      <li data-x='2' data-y='2'><span>${this.state[2][2] || ''}</span></li>
    </ul>
    `

    document.querySelectorAll('#board ul li').forEach((li) => {
      li.addEventListener('click', (event) => {
        let x = event.target.attributes['data-x'].value
        let y = event.target.attributes['data-y'].value
        this.onClick(x, y)
      }, false)
    })
  }
}
