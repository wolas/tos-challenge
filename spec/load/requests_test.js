import http from 'k6/http';
import { check, sleep } from 'k6';

// Configuration for the test
export let options = {
    vus: 200,
    duration: '60s'
};

// Function to generate a random date
function randomDate(startDate, endDate) {
    // Convert input dates to Date objects and normalize to start of day
    const start = new Date(startDate);
    start.setHours(0, 0, 0, 0);
    const end = new Date(endDate);
    end.setHours(23, 59, 59, 999);

    // Calculate total days between start and end
    const oneDay = 24 * 60 * 60 * 1000;
    const totalDays = Math.floor((end - start) / oneDay);

    // Calculate max separation (2 months, approximately 60 days)
    const maxDaysApart = 60;

    // Generate first random day
    const firstDayOffset = Math.floor(Math.random() * (totalDays + 1));
    const firstDate = new Date(start.getTime() + firstDayOffset * oneDay);
    firstDate.setHours(0, 0, 0, 0);

    // Calculate min and max bounds for second date (within 60 days)
    const minSecond = new Date(Math.max(start, new Date(firstDate.getTime() - maxDaysApart * oneDay)));
    const maxSecond = new Date(Math.min(end, new Date(firstDate.getTime() + maxDaysApart * oneDay)));

    // Calculate days available for second date
    const minSecondDays = Math.floor((minSecond - start) / oneDay);
    const maxSecondDays = Math.floor((maxSecond - start) / oneDay);

    // Generate second random day, ensuring it's different from first
    let secondDayOffset;
    do {
        secondDayOffset = Math.floor(Math.random() * (maxSecondDays - minSecondDays + 1)) + minSecondDays;
    } while (secondDayOffset === firstDayOffset);

    const secondDate = new Date(start.getTime() + secondDayOffset * oneDay);
    secondDate.setHours(0, 0, 0, 0);

    // Sort dates to ensure chronological order
    const [date1, date2] = [firstDate, secondDate].sort((a, b) => a - b);

    return [new Date(date1).toISOString().split('T')[0], new Date(date2).toISOString().split('T')[0]];
}

export default function () {
    // Define date range for 2021-2025
    const startOf2021 = new Date('2021-01-01');
    const endOf2025 = new Date('2025-12-31');

    // Generate random starts_at and ends_at within 2021
    const [start, end] = randomDate(startOf2021, endOf2025);

    // Construct the URL with query parameters
    const url = `https://fever-a67c769024cf.herokuapp.com/search?starts_at=${start}&ends_at=${end}&cached=false`;

    // Send GET request
    let res = http.get(url);

    // Validate response
    check(res, {'status is 200': (r) => r.status === 200,});

    // Small delay to avoid overwhelming the server
    sleep(0.01); // 10ms delay between requests per VU
}