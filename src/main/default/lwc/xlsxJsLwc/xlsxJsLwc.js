/*
EXPECTED DATA FORMAT:
{
  fileName: STRING,
  autoDownload: Boolean,
  columnFilters: Boolean,
  sheets: [
    {
      sheetName: STRING,
      header: [STRING, STRING, ...],
      rows:[[STRING, STRING, ....], [STRING, STRING, ....]] 
    },
    {
      sheetName: STRING,
      header: [STRING, STRING, ...],
      rows:[[STRING, STRING, ....], [STRING, STRING, ....]] 
    },
    ....
  ]
}
*/

import { loadScript } from "lightning/platformResourceLoader";
import XLSX from "@salesforce/resourceUrl/xlsxJsStyle";

export default class XlsxJsLwc {
  xlsx;

  constructor() {
  }

  loadResources() {
    return new Promise((resolve) => {
      loadScript(this, XLSX + "/xlsx.bundle.js").then(() => {
        this.xlsx = window.XLSX;
        resolve();
      });
    });
  }

  createAndDownloadFile(data) {
    return new Promise((resolve, reject) => {
      try {
        const autoDownload =
          Object.keys(data).indexOf("autoDownload") < 0
            ? true
            : data.autoDownload;
        const workBook = this.xlsx.utils.book_new();
        data.sheets.forEach((sheet) => {
          const header = sheet.header;
          const values = sheet.rows;
          const aoa = [header].concat(values);
          const workSheet = this.xlsx.utils.aoa_to_sheet(aoa, {
            cellDates: true
          });
          for (const i in workSheet) {
            if (typeof workSheet[i] != "object") continue;
            let cell = this.xlsx.utils.decode_cell(i);
            workSheet[i].s = {
              // styling for all cells
              font: {
                name: "arial"
              },
              alignment: {
                vertical: "center",
                horizontal: "center",
                wrapText: "0" // any truthy value here
              },
              border: {
                bottom: {
                  style: "thin",
                  color: "000000"
                },
                left: {
                  style: "thin",
                  color: "000000"
                },
                rigth: {
                  style: "thin",
                  color: "000000"
                }
              }
            };
            if (cell.r === 0) {
              // first row
              workSheet[i].s = {
                font: {
                  bold: true,
                  sz: "14",
                  color: { rgb: "FFFFFF" }
                },
                alignment: {
                  vertical: "center",
                  horizontal: "center"
                },
                fill: {
                  type: "pattern",
                  patternType: "solid",
                  fgColor: { rgb: "000000" }
                }
              };
            }
          }
          workSheet["!cols"] = this._fitToColumn(aoa);
          workSheet["!rows"] = aoa.map((row, indx) =>
            indx === 0 ? { hpx: 35 } : { hpx: 20 }
          );

          /* auto filter */
          if (data.columnFilters) {
            const range = this.xlsx.utils.decode_range(workSheet["!ref"]);
            const numRows = range.e.r - range.s.r + 1;
            const numCols = range.e.c - range.s.c;
            const lastColName = this.xlsx.utils.encode_col(numCols);
            const ref = `A1:${lastColName}${numRows}`;
            workSheet["!autofilter"] = { ref: ref };
          }

          this.xlsx.utils.book_append_sheet(
            workBook,
            workSheet,
            sheet.sheetName
          );
        });
        if (autoDownload) {
          this.xlsx.writeFile(workBook, `${data.fileName}.xlsx`, {
            cellDates: true
          });
          resolve();
        } else {
          const wBook = this.xlsx.write(workBook, {
            bookType: "xlsx",
            type: "base64"
          });
          const fileData = {
            fileName: `${data.fileName}.xlsx`,
            base64: wBook
          };
          resolve(fileData);
        }
      } catch (error) {
        reject(error);
      }
    });
  }

  _fitToColumn(data) {
    const widths = [];
    /* eslint-disable */
    for (const field in data[0]) {
      widths.push({
        wch: Math.max(
          field.length,
          ...data.map((item) => item[field]?.toString()?.length + 5 ?? 0)
        )
      });
    }
    /* eslint-enable */
    return widths;
  }
}
