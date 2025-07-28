import http from 'k6/http';
import { check, sleep } from 'k6';

// Configuration for the test
export let options = {
    vus: 100,
    duration: '60s'
};

// List of possible countries and types
const countries = ['gb', 'es', 'us', 'ca', 'it'];
const types = ['movies', 'tv_shows', 'channels'];

export default function () {
    const country = countries[Math.floor(Math.random() * countries.length)];
    const type = types[Math.floor(Math.random() * types.length)];

    const url = `http://localhost:3000/contents?country=${country}&type=${type}`;

    let res = http.get(url);

    check(res, { 'status is 200': (r) => r.status === 200 });

    sleep(0.01); // 10ms delay between requests per VU
}