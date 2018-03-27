import Papa from "papaparse";

var max_rows = 10;

function getFile() {
  return document.getElementById("file-upload").files[0];
}

function clearPreviewTable() {
  document.getElementById("table").style.display = "none";
  document.getElementById("table-body").innerHTML = "";
}

function appendPreviewRow(phoneNumber) {
  document.getElementById("table").style.display = "block";
  var html = `<td>${phoneNumber}</td>`;
  var el = document.createElement("tr");
  el.innerHTML = html;
  document.getElementById("table-body").appendChild(el);
}

document.getElementById("col-num").onchange = function(ev) {
  clearPreviewTable();

  var rows_seen = 0;
  var file = getFile();

  if (file) {
    Papa.parse(file, {
      header: false,
      step: function(results, parser) {
        if (rows_seen > 0) {
          appendPreviewRow(results.data[0][ev.target.value - 1]);
        }

        rows_seen++;

        if (rows_seen > max_rows) {
          parser.pause();
        }
      }
    });
  }
};
