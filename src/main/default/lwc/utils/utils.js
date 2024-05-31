const reduceErrors = (errors) => {
  if (!Array.isArray(errors)) {
    errors = [errors];
  }
  return (
    errors
      // Remove null/undefined items
      .filter((error) => !!error)
      // Extract an error message
      .map((error) => {
        // UI API read errors
        if (Array.isArray(error.body)) {
          return error.body.map((e) => e.message);
        }
        // UI API DML, Apex and network errors
        else if (error.body && typeof error.body.message === "string") {
          return error.body.message;
        }
        // JS errors
        else if (typeof error.message === "string") {
          return error.message;
        }
        // Unknown error shape so try HTTP status text
        return error.statusText;
      })
      // Flatten
      .reduce((prev, curr) => prev.concat(curr), [])
      // Remove empty strings
      .filter((message) => !!message)
  );
};

const DateUtils = {
  addDays: (theDate, numDays) => {
    let result = new Date(theDate);
    result.setDate(result.getDate() + numDays);
    return result;
  },
  getMonday: (d) => {
    d = new Date(d);
    const day = d.getDay(),
      diff = d.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is sunday
    return new Date(d.setDate(diff));
  },
  buildDayString: (theDate, includeYear) => {
    const params = {
      day: "numeric",
      month: "short"
    };
    if (includeYear) {
      params.year = "numeric";
    }
    return theDate.toLocaleString("en-us", params);
  },
  toApexDate: (d) => {
    const params = {
      year: "numeric",
      month: "2-digit",
      day: "2-digit"
    };
    const day = d.toLocaleDateString("en-CA", { day: "2-digit" });
    const month = d.toLocaleDateString("en-CA", { month: "2-digit" });
    // const ds = d.toLocaleDateString("en-CA");
    //const ds2 = `${d.getFullYear()}-${month}-${day}`;
    const ds3 = d.toLocaleDateString("en-CA", params);
    return ds3;
  },
  dateFromApexDate: (apexDate) => {
    const dateSplit = apexDate.split("-");
    return new Date(dateSplit[0], dateSplit[1] - 1, dateSplit[2]);
  },
  dayOfWeekToday: () => {
    const today = new Date();
    return today.getDay() === 0 ? 6 : today.getDay() - 1;
  }
};

export { reduceErrors, DateUtils };
