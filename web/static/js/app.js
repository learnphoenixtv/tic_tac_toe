import "phoenix_html"
import {Socket} from 'phoenix'
import Board from './board'

let socket = new Socket("/socket", {params: {}})
socket.connect()

let boardContainer = document.getElementById('board')
let gameId = boardContainer.attributes['data-game-id'].value

let channel = socket.channel(`game:${gameId}`)

channel.join()
  .receive('error', resp => {
    alert(`Sorry, you can't join because ${resp.reason}`)
  })

channel.on('update_board', payload => {
  let board = new Board(payload.board)

  board.onClick((x, y) => {
    channel.push('select', {coord: [x, y]})
      .receive('error', resp => alert(resp.reason))
  })

  board.draw(boardContainer)
})

channel.on('your_turn', payload => {
  alert('Your turn!')
})

channel.on('winner', payload => {
  alert(`${payload.player || 'No one'} wins!`)
})
