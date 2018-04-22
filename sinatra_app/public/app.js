$(function() {
  let delay = 0
  if(document.location.href.match(/random_delay/)) {
    delay = parseInt((Math.random() * 800) + 200)
  }

  $('#welcome_modal').dialog({
    autoOpen: false
  });

  $('#top_menu').controlgroup();

  ['index', 'calculator', 'todos', 'form'].forEach((el) => {
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
      let nameSpan = document.createElement('span')
      nameSpan.innerText = newText
      nameSpan.setAttribute('role', 'name')
      let rmA = document.createElement('a')
      rmA.setAttribute('role', 'rm')
      rmA.onclick = rmTodoItem
      rmA.innerText = '[rm]'
      newLi.appendChild(nameSpan)
      newLi.appendChild(rmA)
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

  $('a[role="rm"]').click(rmTodoItem)

  $('#welcome_modal_opener').on('click', function() {
    $('#welcome_modal').dialog('open');
  });
});
