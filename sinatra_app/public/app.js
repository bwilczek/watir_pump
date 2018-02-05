$(function() {
  let delay = 0
  if(document.location.href.match(/random_delay/)) {
    delay = parseInt((Math.random() * 800) + 200)
  }

  $('#welcome_modal').dialog({
    autoOpen: false
  });

  $('#top_menu').controlgroup();

  ['index', 'calculator', 'todos'].forEach((el) => {
    $(`#link_${el}`).click(() => {
      console.log(document.location.href)
      let new_href = document.location.href.replace(/[a-z]+.html$/, `${el}.html`)
      document.location.href = new_href
    })
  });

  setTimeout(() => {
    $('div[role="todo_list"]').show()
  }, delay)

  $('div[role="todo_list"] button').click((e) => {
    setTimeout(() => {
      let newText = e.target.parentNode.querySelector('input').value
      if(newText == '') {
        return
      }
      let ul = e.target.parentNode.querySelector('ul')
      let newLi = document.createElement('li')
      let rmSpan = document.createElement('span')
      rmSpan.setAttribute('role', 'rm')
      rmSpan.onclick = rmTodoItem
      newLi.innerText = newText
      rmSpan.innerText = '[rm]'
      newLi.appendChild(rmSpan)
      ul.appendChild(newLi)
      e.target.parentNode.querySelector('input').value = ''
    }, delay)
  })

  rmTodoItem = (e) => {
    setTimeout(() => {
      let li = e.target.parentNode
      li.parentNode.removeChild(li)
    }, delay)
  }

  $('span[role="rm"]').click(rmTodoItem)

  $('#welcome_modal_opener').on('click', function() {
    $('#welcome_modal').dialog('open');
  });
});
