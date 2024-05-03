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

// Generate dates used in filters, which contains today along with the next seven days.
//
// It returns two format of the same date. First is the one used in runnerData and second
// is used to display.
//
// Example output:
//
//   ['Sat Feb 03, 2024', 'Feb 3, Sat']
//   ['Sun Feb 04, 2024', 'Feb 4, Sun']
//   ['Mon Feb 05, 2024', 'Feb 5, Mon']
//   ['Tue Feb 06, 2024', 'Feb 6, Tue']
//   ['Thu Feb 08, 2024', 'Feb 8, Thu']
//   ['Fri Feb 09, 2024', 'Feb 9, Fri']
//   ['Sat Feb 10, 2024', 'Feb 10, Sat']
//   ['Sun Feb 11, 2024', 'Feb 11, Sun']
//
const generateDates = () => {
  const today = new Date();
  const daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
  const dates = [];

  for (let i = 0; i < 8; i++) {
    const nextDate = new Date(today);
    nextDate.setDate(today.getDate() + i);

    const dayOfWeek = daysOfWeek[nextDate.getDay()];
    const month = nextDate.toLocaleString("en", { month: "short" });
    const day = String(nextDate.getDate()).padStart(2, "0");
    const day2 = nextDate.getDate();
    const year = nextDate.getFullYear();

    const filterDate = `${dayOfWeek} ${month} ${day}, ${year}`;
    const displayDate = `${month} ${day2}, ${dayOfWeek}`;
    dates.push([filterDate, displayDate]);
  }
  return dates;
};

const renderDateFilters = (runnerData) => {
  const dates = generateDates();
  const dateFilters = [];
  dateFilters.push(`
    <p>
      <nav class="nav nav-pills nav-justified" id="date-filters-nav">
        <a class="nav-item nav-link active" href="#" data-date="All">All</a>
  `);
  for (let i = 0; i < dates.length; i++) {
    const [filterDate, displayDate] = dates[i];
    dateFilters.push(`
          <a class="nav-item nav-link" href="#" data-date="${filterDate}">${displayDate}</a>
    `);
  }
  dateFilters.push(`
      </nav>
    </p>
  `);

  $("#date-filters").html(dateFilters.join("\n"));

  $("#date-filters-nav a").on("click", function (e) {
    $("#date-filters-nav a.active").removeClass("active");

    e.preventDefault();
    $(this).addClass("active");

    const date = $(this).data("date");
    console.log("select date: " + date);
    renderVenueVacancies(runnerData, date);
  });
};

const renderVenueVacancies = (runnerData, dateFilter) => {
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
    var venueVacancyCount = 0;
    var rows = [];
    for (let date in dateVacancies) {
      if ((dateFilter !== "All") & (date != dateFilter)) {
        continue;
      }

      var vacancies = dateVacancies[date];
      var hasShownDate = false;

      for (let i = 0; i < vacancies.length; i++) {
        var vacancy = vacancies[i];
        if (dateFilter == "All") {
          rows.push(`
            <tr>
              <td scope="row">${hasShownDate ? "" : date}</td>
              <td>${vacancy.start_time} - ${vacancy.end_time}</td>
              <td>(${vacancy.duration})</td>
              <td>${vacancy.court_info}</td>
            </tr>
          `);
          hasShownDate = true;
          venueVacancyCount++;
        } else {
          rows.push(`
            <tr>
              <td scope="row">${vacancy.start_time} - ${vacancy.end_time}</td>
              <td>(${vacancy.duration})</td>
              <td>${vacancy.court_info}</td>
            </tr>
          `);
          venueVacancyCount++;
        }
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
          <ul class="list-group">
            <li class="list-group-item d-flex justify-content-between align-items-center" style="background: transparent;border: transparent;">
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
              <span class="badge badge-primary badge-pill">${venueVacancyCount > 0 ? venueVacancyCount : ""}</span>
            </li>
          </ul>
        </div>

        ${collapsedTable}
      </div>
    `);
  }
  card.push("</div>");

  $("#vacancies-list").html(card.join("\n"));
  $(".collapse").collapse();
};

$(document).ready(function () {
  console.log(runnerData);

  const updatedAt = renderUpdatedAt(runnerData.updated_at);

  $("#last-updated-at").text(
    `Last updated at: ${updatedAt} (update every ~10 min)`,
  );

  // renderDateFilters(runnerData);

  renderVenueVacancies(runnerData, "All");
});
