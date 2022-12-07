$(document).ready(function () {
  console.log(runnerData);

  $("#last-updated-at").text(
    `Last updated at: ${runnerData.updated_at} (update every ~10 min)`,
  );

  var card = [`<div id="accordion">`];
  for (let venue in runnerData.venues) {
    var venueData = runnerData.venues[venue];
    var venueTitle = `${venueData.city} - ${venueData.name}`;
    var venueSite = venueData.site;
    var venueDaysVisible = venueData.visibleDays;

    var dateVacancies = runnerData.vacancies[venue];
    var errored = dateVacancies.errored;
    var rows = [];
    for (let date in dateVacancies) {
      var vacancies = dateVacancies[date];
      var hasShownDate = false;

      for (let i = 0; i < vacancies.length; i++) {
        var vacancy = vacancies[i];
        rows.push(
          `
          <tr>
            <td scope="row">${hasShownDate ? "" : date}</td>
            <td>${vacancy.start_time} - ${vacancy.end_time}</td>
            <td>(${vacancy.duration})</td>
            <td>${vacancy.court_info}</td>
          </tr>
        `,
        );
        hasShownDate = true;
      }
    }

    var table = `
      <div class="table-responsive">
        <table class="table table-striped table-bordered">
          <tbody>
            ${rows.join("\n")}
          </tbody>
        </table>
      </div>
    `;

    var alertInfo = errored
      ? `
      <li class="list-inline-item">
      <span class="badge badge-danger">⚠️   Fail to sync</span></li>
    `
      : "";
    var collapsedTable = errored
      ? ""
      : `
        <div id="collapse${venue}" class="collapse show" aria-labelledby="heading${venue}" data-parent="#accordion">
          <div class="card-body">
          ${table}
          </div>
        </div>
    `;
    card.push(`
      <div class="card">
        <div class="card-header" id="heading${venue}">
            <ul class="list-inline" style="margin-bottom: 0">
              <li class="list-inline-item">
                <button class="btn btn-link" data-toggle="collapse" data-target="#collapse${venue}" aria-expanded="true" aria-controls="collapse${venue}">
                  <h5 style="margin-bottom: 0">${venueTitle}</h5>
                </button>
              </li>
              <li class="list-inline-item"><a href="${venueSite}" target="_blank">(Link)</a></li>
              <li class="list-inline-item">(${venueDaysVisible} days visible)</li>
              ${alertInfo}
            </ul>
        </div>

        ${collapsedTable}
      </div>
    `);
  }
  card.push("</div>");
  $("#vacancies-list").html(card.join("\n"));
});
