function paginate(rowCount, perPage, currentPage, functionName) {
    console.log(rowCount + "<=" + perPage)
    var totalPages = Math.ceil(rowCount / perPage);
    if (totalPages<=1) return "";
    var htm = "";
    console.log(currentPage);
    htm += '<nav aria-label="Page navigation example"><ul class="pagination justify-content-center">';
    if (currentPage > 1) {
        htm += '<li class="page-item"><a class="page-link" href="javascript:void(0);" onclick="' + functionName + '(1)">First</a></li>';
        htm += '<li class="page-item"><a class="page-link" href="javascript:void(0);" onclick="' + functionName + '(' + (currentPage - 1) + ')">‹ Prev</a></li>';
    }
    for (var i = currentPage - 2; i < currentPage; i++) {
        if (i > 0) {
            htm += '<li class="page-item"><a class="page-link" href="javascript:void(0);" onclick="' + functionName + '(' + i + ')">' + i + '</a></li>';
        }
    }
    htm += '<li class="page-item"><span class="test">' + currentPage + '</span>';
    for (var i = currentPage + 1; i < currentPage + 3 && i <= totalPages; i++) {
        htm += '<li class="page-item"><a class="page-link" href="javascript:void(0);" onclick="' + functionName + '(' + i + ')">' + i + '</a></li>';
    }
    if (currentPage < totalPages) {
        htm += '<li class="page-item"><a class="page-link"href="javascript:void(0);" onclick="' + functionName + '(' + (currentPage + 1) + ')">Next ›</a></li>';
        htm += '<li class="page-item"><a class="page-link"href="javascript:void(0);" onclick="' + functionName + '(' + totalPages + ')">Last</a></li></ul></nav>';
    }
    return htm;

}