// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require bootstrap-sprockets
//= require bootstrap-select
//= require turbolinks
//= require spin
//= require_tree .

var tty = [], name_comport = [], model_switch = [], switch_loading_time = []
var i = [], exit_count = 0, result = []

$(document).ready(function(){ 
 $('#submit').prop('disabled', true);
  $('.all_checkbox').click(function(){    
    if ($("input:checkbox:checked").length == 0 ) {
      document.getElementById('not_checked').innerHTML = 'не стоит не одна галочка';
      $('#submit').prop('disabled', true);
    } else {
      document.getElementById('not_checked').innerHTML = ' ';
      $('#submit').prop('disabled', false);
    }
  })
})

function SetDelay (k) {
  delayTime = setTimeout (function(){ DisabledObject(k) },switch_loading_time[k]*10);
}

function DisabledObject (k) {   
  document.getElementById('th_progress'+k).innerHTML =  i[k]+"%";
  document.getElementById('th_progress'+k).style.width = i[k]+"%"; 
  if (i[k]<100) {
    ChekigStatus (k)
    i[k] = i[k] + 1
    SetDelay (k)
  }else{
    exit_count += 1
    if (i.length == exit_count) {  
      $.ajax({
        url: "switch_test/logging",
        type: "POST",
        data: {tty: tty, result: result, name_comport: name_comport, model_switch: model_switch},
        success: function(data){ 
          $('#submit').prop('disabled', false);
          $('.all_checkbox').prop('disabled', false);
          $('.select').prop('disabled', false);
          i = []
          name_comport = []
          model_switch = []
          switch_loading_time = []
          tty = []
          exit_count = 0
          result = []
        }
      })   
    }
  }
  
}

function SetData () {
  CreateElements ()
  ChekigStatus ()
  for (var k = 0; k < switch_loading_time.length; k++){
    i[k] = 1
    SetDelay (k)
  }
 }

function CreateElements () {
  var div = document.getElementById("table_progress")
  while(div.firstChild){
    div.removeChild(div.firstChild);
  }
  var table = document.createElement("TABLE")
  table.classList.add('table')
  table.classList.add('table-bordered')
  table.classList.add('table-striped')  
  for (var quantity = 0; quantity < model_switch.length; quantity++){
    var tr = document.createElement("TR")
    var th_switch_model = document.createElement("TH")
    var th_progress = document.createElement("TH")
    var th_result = document.createElement("TH")
    th_switch_model.classList.add('col-md-1')
    th_switch_model.id = "th_switch_model"+ quantity
    th_progress.classList.add('progress-bar')
    th_progress.classList.add('progress-bar-success')
    th_progress.style.width = "0%"
    th_progress.innerHTML =  "0%";
    th_progress.id = "th_progress"+quantity
    th_switch_model.innerHTML = name_comport[quantity] + "(" + model_switch[quantity] +")"
    th_result.classList.add('col-md-4')
    th_result.id = "th_result"+quantity    
    table.appendChild(tr)
    tr.appendChild(th_switch_model)
    tr.appendChild(th_progress)
    tr.appendChild(th_result)
  }
  div.appendChild(table)
}


function ChekigStatus (k) {
  $.ajax({
      url: "switch_test/status_result",
      type: "POST",
      data: {name_comport: name_comport[k]},
      success: function(data){
        if (data.result != null) 
          {
            result[k] = data.result
           document.getElementById('th_result'+k).innerHTML = data.result 
          i[k] = 100
          }
        }
  })   
}


