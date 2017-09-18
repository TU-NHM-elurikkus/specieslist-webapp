//= require jquery
//= require facets
//= require getQueryParam
//= require jquery-ui
//= require jquery.doubleScroll
//= require ekko-lightbox-5.2.0
//= require common

$(document).ready(function() {
    // Add scroll bar to top and bottom of table $('.fwtable').doubleScroll(); Tooltip for link title
    $('#content a').not('.thumbImage').tooltip({ placement: 'bottom', html: true, delay: 200, container: 'body' });

    $('#edit-meta-button').click(function(el) {
        el.preventDefault();
        toggleEditMeta(!$('#edit-meta-div').is(':visible'));
    });

    // make table header cells clickable
    $('table .sortable').each(function(i) {
        var href = $(this).find('a').attr('href');

        $(this).click(function() {
            window.location.href = href;
        });
    });

});

function toggleEditMeta(showHide) {
    $('#edit-meta-div').slideToggle(showHide);
    $('#show-meta-dl').slideToggle(!showHide);
}

function getFooter(recordId) {
    // read header values from the table
    var headerRow = $('table#speciesListTable > thead th').not('.action');
    var headers = [];
    var footerContent = '';

    headerRow.splice(2, 1); // Don't include Image column into modal

    $(headerRow).each(function(i, el) {
        headers.push($(this).text());
    });

    // read species row values from the table
    var valueTds = $('tr#row_' + recordId + ' > td').not('.action');
    var values = [];

    $(valueTds).each(function(i, el) {
        if(i !== 2) {
            // Don't include Image values
            var val = $(this).html();
            if(typeof val === 'string') {
                val = val.trim();
            }
            values.push(val);
        }
    });

    footerContent += '<div class="row"><div class="col-sm-10">';

    $.each(headers, function(i, el) {
        footerContent +=
            '<b>' +
                el +
            ':</b>&nbsp;' + values[i] +
            '<br />';
    });
    footerContent += '</div></div>';

    return footerContent;
}

$(document).on('click', '[data-toggle="lightbox"]', function(event) {
    event.preventDefault();
    $(this).ekkoLightbox();
    $(this).attr('data-footer', getFooter($(this).attr('data-id')));
});
