//= require jquery
//= require facets
//= require getQueryParam
//= require jquery-ui
//= require ekko-lightbox-5.2.0
//= require common

$(document).ready(function() {
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

    $('.modal-content').on('load', function(event) {
        event.preventDefault();
    });
});

function toggleEditMeta(showHide) {
    $('#edit-meta-div').slideToggle(showHide);
    $('#show-meta-dl').slideToggle(!showHide);
}

function getFooter(recordId) {
    // read header values from the table
    var headerRow = $('#speciesListTable > thead th').not('.action');
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

    footerContent += '<div>';

    $.each(headers, function(i, el) {
        footerContent +=
            '<div>' +
            '<b>' +
            el +
            ':</b>&nbsp;' +
            values[i] +
            '</div>';
    });

    footerContent += '</div>';

    return footerContent;
}

$(document).on('click', '[data-toggle="lightbox"]', function(event) {
    event.preventDefault();
    $(this).ekkoLightbox({
        onContentLoaded: function(elem) {
            // Add footer to gallery modal view on load
            var data_id = this._$element[0].dataset.id;
            var footer = $('.ekko-lightbox .modal-footer');

            footer.html(getFooter(data_id));
            footer.show();
        }
    });
});
