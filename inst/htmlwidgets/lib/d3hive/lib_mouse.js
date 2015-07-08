// lib_mouse.js

var setup_mouse = function(plot_info) {

  var g = plot_info.global;

  // Initialize the info display.

  var default_precis,
      formatNumber  = d3.format(',d'),
      indent        = '&nbsp;&nbsp;';

  var notes   = d3.select(g.selector + ' .notes')

  var precis  = d3.select(g.selector + ' .precis')
    .text(default_precis = 'Showing ' + formatNumber(g.links.length)
             + ' dependencies among ' + formatNumber(g.nodes.length)
             + ' classes.');


  on_mouseout = function() {
  //
  // Clear any highlighted nodes or links.

    g.svg.selectAll('.active_ib').classed('active_ib', false);
    g.svg.selectAll('.active_im').classed('active_im', false);
    g.svg.selectAll('.active_mo').classed('active_mo', false);

    notes.html('');
    precis.text(default_precis);
  }


  on_mouseover_h = function(css_class, html_inp) {
  //
  // Helper for on_mouseover_{link,node}.

    if (!html_inp) return '';

    if (css_class == 'ib')
      hdr  = '<h4 class="ib">Imported by:</h4>';
    else
      hdr  = '<h4 class="im">Imports:</h4>';

    return '<span class="' + css_class+ '">'
         + hdr + html_inp + '</span>';
  };


  on_mouseover_link = function(orig_link) {
  //
  // Highlight the link and connected nodes on mouseover.
  //
  // Mousing over a link should cause:
  //
  //   the link to turn red
  //   the nodes that it imports to turn green
  //   the nodes that import it  to turn blue
  //   the sidebar to show consistent colors and text

    var trace     = false;

    var link_mo   = function(curr_link) {
      var result  = curr_link === orig_link;

//    if (result) console.log('link_mo', curr_link, orig_link); //T
      return result;
    };

    var node_ib  = function(curr_node) {
      var curr_name   = curr_node.node.name;
      var orig_name   = orig_link.source.node.name;

      var result      = curr_name === orig_name;

      if (trace && result) console.log('node_ib',
        curr_name, curr_node, orig_name, orig_link); //T
      return result;
    };

    var node_im  = function(curr_node) {
      var curr_name   = curr_node.node.name;
      var orig_name   = orig_link.target.node.name;

      var result      = curr_name === orig_name;

      if (trace && result) console.log('node_im',
       curr_name, curr_node, orig_name, orig_link); //T
      return result;
    };

    g.svg.selectAll('.link'        ).classed('active_mo', link_mo);

    g.svg.selectAll('.node ellipse').classed('active_ib', node_ib);
    g.svg.selectAll('.node ellipse').classed('active_im', node_im);

    var src_name  = orig_link.source.node.name;
    var tgt_name  = orig_link.target.node.name;

    var html_ib   = on_mouseover_h('ib', src_name);
    var html_im   = on_mouseover_h('im', tgt_name);
    var html      = '<h3 class="mo">Link</h3>'
                  + html_ib + html_im;

    notes.html(html);

    precis.text(src_name + ' -> ' + tgt_name);
  }


  on_mouseover_node = function(orig_node) {
  //
  // Highlight the node and connected links on mouseover.
  //
  // Mousing over a node should cause:
  //
  //   the node (and its clone, if any)    to turn red
  //   the links and nodes that it imports to turn green
  //   the links and nodes that import it  to turn blue
  //   the sidebar to show consistent colors and text

    var trace     = false;

    var link_ib  = function(curr_link) {
      var curr_name   = curr_link.target.node.name;
      var orig_name   = orig_node.node.name;

      var result = curr_name === orig_name;
      if (trace && result) console.log('link_ib',
        curr_name, curr_link, orig_name, orig_node); //T
      return result;
    };

    var link_im  = function(curr_link) {
      var curr_name   = curr_link.source.node.name;
      var orig_name   = orig_node.node.name;

      var result = curr_name === orig_name;
      if (trace && result) console.log('link_im',
        curr_link, orig_node); //T
      return result;
   };

    var node_ib  = function(curr_node) {
      var curr_name   = curr_node.node.name;
      var orig_name   = orig_node.node.name;
      var curr_tgts   = g.targets[curr_name];
      var result      = false;

      if (curr_tgts) {
        for (curr_tgt in curr_tgts)
          if (curr_tgt === orig_name) result = 'target';
      }

      if (trace && result) console.log('node_ib',
        curr_name, curr_node, orig_name, orig_node, curr_tgts, result); //T
      return result;
    };

    var node_im  = function(curr_node) {
      var curr_name   = curr_node.node.name;
      var orig_name   = orig_node.node.name;
      var curr_srcs   = g.sources[curr_name];
      var result      = false;

      if (curr_srcs) {
        for (curr_src in curr_srcs)
          if (curr_src === orig_name) result = 'source';
      }

      if (trace && result) console.log('node_im',
        curr_name, curr_node, orig_name, orig_node, curr_srcs, result); //T
      return result;
    };

    var node_mo = function(curr_node) {
      var curr_name   = curr_node.node.name;
      var orig_name   = orig_node.node.name;
      var result      = false;

      if (curr_name === orig_name) result = 'same or clone';

      if (trace && result) console.log('node_mo',
        curr_name, curr_node, orig_name, orig_node, result); //T
      return result;
    };

    g.svg.selectAll('.link'         ).classed('active_ib', link_ib);
    g.svg.selectAll('.link'         ).classed('active_im', link_im);

    g.svg.selectAll('.node ellipse' ).classed('active_ib', node_ib);
    g.svg.selectAll('.node ellipse' ).classed('active_im', node_im);
    g.svg.selectAll('.node ellipse' ).classed('active_mo', node_mo);

    var src_tmp   = g.sources[orig_node.node.name];
    var sources   = src_tmp ? Object.keys(src_tmp).sort().join('<br>') : '';

    var targets   = orig_node.node.imports.sort().join('<br>');

    var html_ib   = on_mouseover_h('ib', sources);
    var html_im   = on_mouseover_h('im', targets);
    var html      = '<h3 class="mo">Node</h3>'
                  + '<span class="mo">' + orig_node.node.name + '</span>'
                  + html_ib + html_im;

    notes.html(html);

    precis.text(orig_node.node.name);
  }
};
