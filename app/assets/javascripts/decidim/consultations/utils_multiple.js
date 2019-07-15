/* eslint-disable no-invalid-this, no-undefined */


$(function () {
  var MAX_SUPLENTS=$('#remaining-votes-count').data('suplents-number') || 2;
  var MAX_CANDIDATS = $('#remaining-votes-count').text() - MAX_SUPLENTS;
  // console.log('MAX_CANDIDATS', MAX_CANDIDATS, 'MAX_SUPLENTS', MAX_SUPLENTS)
  // Search for suplents
  var SUPLENTS = [];
  var s_regex = /([\- ]+)(suplente?)([\- ]+)/i;
  var b_regex = /([\- ]+)(en blanco?)([\- ]+)/i;
  $('form .multiple_votes_form label').each(function(){
    var $label = $(this);

    if($label.text().match(s_regex)) {
      var bold = $label.text().replace(s_regex, " <strong>-$2-</strong>");
      // console.log('found suplent', 'BOLD', bold, 'LABEL', $label)
      $label.html(bold);
    }
    if($label.text().match(b_regex)) {
      var bold = $label.text().replace(b_regex, " <strong>-$2-</strong>");
      // console.log('found suplent', 'BOLD', bold, 'LABEL', $label)
      $label.html(bold);
    }
  });

  var $remainingVotesCount = $('#remaining-votes-count');
  var groups = 'form .multiple_votes_form_group_title input[type="checkbox"]';
  var inputs = 'form .multiple_votes_form input[type="checkbox"]';
  var candidats = MAX_CANDIDATS;
  var suplents = MAX_SUPLENTS;
  var $blanc = null;

  function isSuplent($input) {
    return $input.parent().find('label').text().match(s_regex);
  }
  function isBlanc($input) {
    return $input.parent().find('label').text().match(b_regex);
  }
  function updateCounters() {
    candidats = MAX_CANDIDATS;
    suplents = MAX_SUPLENTS;
    $blanc = null;
    $(inputs + ':checked').each(function() {
      if(isSuplent($(this))) suplents--;
      else candidats--;
      if(isBlanc($(this))) $blanc = $(this);
    });
  }
  function updateBanner() {
    $remainingVotesCount.text(candidats + suplents);
    // If group marked, set to zero
    if($(groups).is(':checked') || $blanc) {
      $remainingVotesCount.text(0);
    }
  }

  $(inputs).on('change', function() {

    updateCounters();
    if(isBlanc($(this))) {
      $(inputs).not($(this)).prop('checked', false);
      $(groups).prop('checked', false);
      // check closest group if exists
      $(this).closest('.card').find('.multiple_votes_form_group_title input').prop('checked', true);
      updateBanner();
      return;
    } else {
      // console.log('unclick blanc', $blanc);
      // unclick blanc
      if($blanc) {
        $blanc.prop('checked', false);
        $blanc = null;
      }
    }
    // console.log('candidats', candidats, 'suplents', suplents, 'isBlanc', isBlanc($(this)), 'blanc', $blanc)
    if(candidats < 0 || suplents < 0) {
      $(this).attr('checked', false);
      if(suplents <0 ) alert('Ja has triat el nombre màxim de suplents!');
      else alert('Ja has triat el nombre màxim de candidats!');
      return false;
    }
    // unmark groups if manually changed
    $(groups).prop('checked', false);
    updateBanner();
  });

  // Group click handeling
  $(groups).on('change', function() {
    var $group = $(this);
    if($group.is(':checked')) {
      // uncheck other inputs
      $(inputs).prop('checked', false);
      // uncheck other groups
      $(groups).not($(this)).prop('checked', false);
      $group.closest('.card').find('.multiple_votes_form input[type="checkbox"]').each(function(){
        updateCounters();

        var can_and_is_suplent = isSuplent($(this)) && suplents > 0;
        var can_and_is_candidat = !isSuplent($(this)) && candidats > 0;
        if(can_and_is_suplent || can_and_is_candidat) {
          $(this).prop('checked', true);
          updateBanner();
        }
      });
    }
  });

  $form = $('form .multiple_votes_form').closest('form');

  $form.on('submit', function() {
    // If groups are checked, bypasses counters
    if($(groups).is(':checked')) {
      return true;
    }
    // If blanc is checked, bypasses counters
    if($blanc && $blanc.is(':checked')) {
      return true;
    }
    updateCounters();
    if(candidats > 0) {
      alert('Encara et falten votar ' + candidats + ' candidats');
      return false;
    }
    else if(suplents > 0) {
      alert('Encara et falten votar ' + suplents + ' suplents');
      return false;
    }
  });
});
