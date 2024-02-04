function renderUpdatedAt(datetimeString) {
  // appends green circle when updatedAt is less than an hour
  // appends yellow circle when updatedAt is less than three hours
  // appends red circle when updatedAt is more than three hours

  // Convert the input string to a Date object
  const inputDate = new Date(datetimeString);

  // Get the current time
  const currentTime = new Date();

  // Calculate the time difference in milliseconds
  const timeDifference = inputDate.getTime() - currentTime.getTime();

  // Convert the time difference to minutes
  const timeDifferenceInMinutes = timeDifference / (1000 * 60);

  // Check if the time difference is less than 60 minutes
  if (Math.abs(timeDifferenceInMinutes) <= 60) {
    return datetimeString + " 🟢";
  } else if (Math.abs(timeDifferenceInMinutes) <= 180) {
    return datetimeString + " 🟡";
  } else {
    return datetimeString + " 🔴";
  }
}

$(document).ready(function () {
  console.log(runnerData);

  const updatedAt = renderUpdatedAt(runnerData.updated_at);

  $("#last-updated-at").text(
    `Last updated at: ${updatedAt} (update every ~10 min)`,
  );

  const dateFilters = `
    <p>
      <nav class="nav nav-pills nav-justified">
        <a class="nav-item nav-link active" href="#">All</a>
        <a class="nav-item nav-link" href="#">2.3 Sat</a>
        <a class="nav-item nav-link" href="#">2.4 Sun</a>
        <a class="nav-item nav-link" href="#">2.5 Mon</a>
        <a class="nav-item nav-link" href="#">2.6 Tue</a>
        <a class="nav-item nav-link" href="#">2.7 Wed</a>
        <a class="nav-item nav-link" href="#">2.8 Thu</a>
        <a class="nav-item nav-link" href="#">2.9 Fri</a>
        <a class="nav-item nav-link" href="#">2.10 Sat</a>
      </nav>
    </p>
  `;
  $("#date-filters").html(dateFilters);

  const card = [];
  card.push(`<div id="accordion">`);

  for (let venue in runnerData.venues) {
    var venueData = runnerData.venues[venue];
    var venueTitle = `${venueData.city} - ${venueData.name}`;
    var venueSite = venueData.site;
    var venueDaysVisible = venueData.visibleDays;
    var venueNote = venueData.note;
    var venueRemark = `${venueDaysVisible} days visible`;
    if (venueNote) {
      venueRemark += `; ${venueNote}`;
    }

    var dateVacancies = runnerData.vacancies[venue];
    if (!dateVacancies) {
      continue;
    }

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
              <li class="list-inline-item"><small><i>(${venueRemark})</i></small></li>
              ${alertInfo}
            </ul>
        </div>

        ${collapsedTable}
      </div>
    `);
  }
  card.push("</div>");

  $("#vacancies-list").html(card.join("\n"));
  $(".collapse").collapse();
});
