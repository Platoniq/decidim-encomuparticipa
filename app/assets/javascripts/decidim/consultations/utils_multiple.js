/* eslint-disable no-invalid-this, no-undefined */


$(function () {
  var MAX_SUPLENTS=$('#remaining-votes-count').data('suplents-number') || 2;
  var MAX_CANDIDATS = $('#remaining-votes-count').text() - MAX_SUPLENTS;
  // console.log('MAX_CANDIDATS', MAX_CANDIDATS, 'MAX_SUPLENTS', MAX_SUPLENTS)
  // Search for suplents
  var SUPLENTS = [];
  var regex = /([\- ]+)(suplent)([\- ]+)/i;
  $('form .multiple_votes_form label').each(function(){
    var $label = $(this);

    if($label.text().match(regex)) {
      var bold = $label.text().replace(regex, " <strong>-$2-</strong>");
      // console.log('found suplent', 'BOLD', bold, 'LABEL', $label)
      $label.html(bold);
    }
  });

  var $remainingVotesCount = $('#remaining-votes-count');
  var groups = 'form .multiple_votes_form_group_title input[type="checkbox"]';
  var inputs = 'form .multiple_votes_form input[type="checkbox"]';
  var candidats = MAX_CANDIDATS;
  var suplents = MAX_SUPLENTS;

  function is_suplent($input) {
    return $input.parent().find('label').text().match(regex);
  }
  function update_counters() {
    candidats = MAX_CANDIDATS;
    suplents = MAX_SUPLENTS;
    $(inputs + ':checked').each(function(){
      if(is_suplent($(this))) suplents--;
      else candidats--;
    });
  }

  $(inputs).on('change', function() {

    update_counters();
    // console.log('candidats', candidats, 'suplents', suplents)
    if(candidats < 0 || suplents < 0) {
      $(this).attr('checked', false);
      if(suplents <0 ) alert('Ja has triat el nombre màxim de suplents!');
      else alert('Ja has triat el nombre màxim de candidats!');
      return false;
    }
    // unmark groups if manually changed
    $(groups).prop('checked', false);
    $remainingVotesCount.text(candidats + suplents);
  });

  // Group click handeling
  $(groups).on('change', function() {
    var $group = $(this);
    if($group.is(':checked')) {
      $(inputs).prop('checked', false);
      $group.closest('.card').find('.multiple_votes_form input[type="checkbox"]').each(function(){
        update_counters();

        var can_and_is_suplent = is_suplent($(this)) && suplents > 0;
        var can_and_is_candidat = !is_suplent($(this)) && candidats > 0;
        if(can_and_is_suplent || can_and_is_candidat) {
          $(this).prop('checked', true);
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
    update_counters();
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
