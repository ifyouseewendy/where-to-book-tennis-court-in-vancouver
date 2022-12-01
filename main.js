$(document).ready(function () {
  console.log(runnerData);

  $("#last-updated-at").text(
    `Last updated at: ${runnerData.updated_at} (update per 5 min)`,
  );

  for (let venue in runnerData.vacancies) {
    var venueData = runnerData.venues[venue];
    var venueTitle = `${venueData.city} - ${venueData.name}`;
    var venueLink = venueData.website;

    var dateVacancies = runnerData.vacancies[venue];
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

    var card = `
      <div id="accordion">
        <div class="card">
          <div class="card-header" id="headingOne">
            <h5 class="mb-0">
              <button class="btn" data-toggle="collapse" data-target="#collapseOne" aria-expanded="true" aria-controls="collapseOne">
      <p class="h4">${venueTitle} <a href="${venueLink}">(Link)</a></p>
              </button>
            </h5>
          </div>

          <div id="collapseOne" class="collapse show" aria-labelledby="headingOne" data-parent="#accordion">
            <div class="card-body">
            ${table}
            </div>
          </div>
        </div>
      </div>
    `;

    $("#vacancies-list").html(card);
  }
});
