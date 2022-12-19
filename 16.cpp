#include <algorithm>
#include <array>
#include <fstream>
#include <iostream>
#include <limits>
#include <map>
#include <queue>
#include <random>
#include <regex>
#include <string>
#include <vector>

// puzzle parameters
const int WORKERS = 2;
const int TIME_LIMIT = 26;

// genetic algorithm parameters
const int POPULATION = 10000;
const int KEEP_BEST = POPULATION / 10;
const int BREED_BEST = POPULATION / 5;
const int PLATEAU = 10; // terminate after this many generations w/o improvement

using namespace std;

struct Valve {
    int id;
    int visited;
    vector<string> links;
};

void find_dists(map<string, Valve> &valves, const string &start, vector<int> &dists)
{
    queue<string> fringe;
    queue<string> next_fringe;
    fringe.push(start);
    int start_id = valves[start].id;
    int dist = 1; // include valve-turn-on time
    do {
        while (!fringe.empty()) {
            string node = fringe.front();
            fringe.pop();
            Valve &valve = valves[node];
            valve.visited = start_id;
            if (valve.id >= 0 && dist < dists[valve.id]) {
                dists[valve.id] = dist;
            }
            for(const string &link: valve.links) {
                if (valves[link].visited != start_id) {
                    next_fringe.push(link);
                }
            }
        }
        ++dist;
        swap(fringe, next_fringe);
    } while(!fringe.empty());
}

int run_tour(const vector<vector<int>> &cost_map, const vector<int> &flows, int start_id, const vector<int> &tour)
{
    array<int, WORKERS> locations;
    array<int, WORKERS> times;
    fill(locations.begin(), locations.end(), start_id);
    fill(times.begin(), times.end(), TIME_LIMIT);

    int pressure_released = 0;
    for(int valve: tour) {
        // choose the next available worker
        size_t turn = max_element(times.begin(), times.end()) - times.begin();
        int location = locations[turn];
        int time_cost = cost_map[location][valve];
        if (times[turn] <= time_cost)
            break;

        times[turn] -= time_cost;
        locations[turn] = valve;
        pressure_released += times[turn] * flows[valve];
    }
    return pressure_released;
}

const int BREED_TIMES = (POPULATION - KEEP_BEST) / (BREED_BEST / 2);

struct Solution {
    vector<int> tour;
    int score;
    bool operator<(const Solution &rhs) const {
        return score > rhs.score; // sort best scores first
    }
};

template <class rnd>
void breed(const Solution &a, const Solution &b, Solution &child, rnd &rg)
{
    size_t size = a.tour.size();
    size_t i0 = rg() % size;
    size_t i1 = rg() % size;
    if (i0 > i1)
        swap(i0, i1);

    for(size_t i = i0; i < i1; ++i)
        child.tour[i] = a.tour[i];

    size_t j = 0;

    auto child_tour_includes_bj = [&]() {
        for(size_t k = i0; k < i1; ++k) {
            if (child.tour[k] == b.tour[j])
                return true;
        }
        return false;
    };

    auto get_unused_valve_from_b = [&]() {
        while (child_tour_includes_bj())
            j++;
        return b.tour[j++];
    };

    for(size_t i = 0; i < i0; ++i)
        child.tour[i] = get_unused_valve_from_b();
    for(size_t i = i1; i < size; ++i)
        child.tour[i] = get_unused_valve_from_b();
}

template <class rnd>
void mutate(Solution &s, rnd &rg)
{
    size_t i0 = rg() % s.tour.size();
    size_t i1 = rg() % s.tour.size();
    swap(s.tour[i0], s.tour[i1]);
}

int find_best_tour(const vector<vector<int>> &cost_map, const vector<int> &flows, int start_id, const vector<int> &prototype_tour)
{
    random_device rd;
    default_random_engine rg(rd());

    // a pair of buffers we can swap between generations, like front and back buffers,
    // with no new memory allocations
    vector<Solution> population(POPULATION, Solution{prototype_tour, 0});
    vector<Solution> next_population(POPULATION, Solution{prototype_tour, 0});

    for(auto &solution: population) {
        shuffle(solution.tour.begin(), solution.tour.end(), rg);
    }

    int best_score = 0;
    int plateau = 0;

    for(;;) {
        for(auto &solution: population) {
            solution.score = run_tour(cost_map, flows, start_id, solution.tour);
        }
        sort(population.begin(), population.end());
        int score = population.front().score;
        if (score < best_score) {
            plateau = 0;
        } else if (score > best_score) {
            cout << score << endl;
            best_score = score;
            plateau = 0;
        } else if (++plateau == PLATEAU) {
            break;
        }

        size_t j = 0;
        for(int i = 0; i < KEEP_BEST; ++i) {
            copy(population[i].tour.begin(), population[i].tour.end(), next_population[j++].tour.begin());
        }
        for(int i = 0; i < BREED_BEST; i += 2) {
            for(int k = 0; k < BREED_TIMES; ++k) {
                breed(population[i], population[i + 1], next_population[j++], rg);
            }
        }
        assert(j == POPULATION);

        for(auto &solution: next_population) {
            mutate(solution, rg);
        }

        swap(population, next_population);
    }

    return best_score;
}

int main(int argc, char **argv)
{
    if (argc < 2) {
        cerr << "no filename given\n";
        return 1;
    }

    map<string, Valve> valves;
    vector<int> flows;
    int next_id = 0;

    regex line_re{R"(Valve ([A-Z][A-Z]) has flow rate=(\d+); tunnels? leads? to valves? ([A-Z][A-Z](?:, [A-Z][A-Z])*))"};
    regex name_re{R"([A-Z][A-Z])"};
    ifstream input{argv[1]};
    string line;
    while(getline(input, line)) {
        smatch match;
        if (regex_match(line, match, line_re)) {
            string name{match[1]};
            int flow{stoi(match[2])};

            Valve v{-1, -1};
            if (name == "AA" || flow > 0) {
                v.id = next_id++;
                flows.push_back(flow);
            }

            string links{match[3]};
            smatch submatch;
            while(regex_search(links, submatch, name_re)) {
                v.links.push_back(submatch.str());
                links = submatch.suffix();
            }

            valves[name] = v;
        }
    }

    vector<vector<int>> cost_map;
    for(int i = 0; i < next_id; ++i)
        cost_map.push_back(vector<int>(next_id, numeric_limits<int>::max()));

    for(auto const& [k, v]: valves) {
        if (v.id >= 0) {
            find_dists(valves, k, cost_map[v.id]);
        }
    }
/*
    for(auto const& [k, v]: valves) {
        cout << v.id << ": " << k << " (";
        cout << (v.id >= 0 ? flows[v.id] : 0) << ") => ";
        for(auto const &n: v.links) {
            cout << n << " ";
        }
        cout << endl;
    }

    cout << "flow rates:" << endl;
    for(int f: flows)
        cout << f << " ";
    cout << endl;

    cout << "cost map:" << endl;
    for(auto const &row: cost_map) {
        for(int v: row) {
            cout.width(3);
            cout << v;
        }
        cout << endl;
    }
*/
    int start_id = valves["AA"].id;
    vector<int> tour;
    for(int i = 0; i < next_id; ++i)
        if (i != start_id) tour.push_back(i);

    find_best_tour(cost_map, flows, start_id, tour);
    return 0;
}
