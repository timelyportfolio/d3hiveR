HTMLWidgets.widget({

  name: 'd3hive',

  type: 'output',

  initialize: function(el, width, height) {

    return {  }

  },

  renderValue: function(el, x, instance) {

    el.innerText = x.message;

  },

  resize: function(el, width, height, instance) {

  }

});
