#include <gnuradio-4.0/Block.hpp>
#include <gnuradio-4.0/Graph.hpp>
#include <gnuradio-4.0/Scheduler.hpp>
#include <gnuradio-4.0/algorithm/ImChart.hpp>
#include <gnuradio-4.0/basic/ClockSource.hpp>
#include <gnuradio-4.0/testing/TagMonitors.hpp>

int main() {
    gr::Graph graph;
    auto& source = graph.emplaceBlock<gr::basic::ClockSource<float>>({{"n_samples_max", 1U}});
    auto& sink = graph.emplaceBlock<gr::testing::TagSink<float, gr::testing::ProcessFunction::USE_PROCESS_BULK>>();
    if (!graph.connect<"out", "in">(source, sink).has_value()) {
        return 1;
    }

    gr::scheduler::Simple<> sched;
    if (!sched.exchange(std::move(graph)).has_value()) {
        return 2;
    }
    if (!sched.runAndWait().has_value()) {
        return 3;
    }

    gr::graphs::ImChart<16, 8> chart({{0.0f, 1.0f}, {0.0f, 1.0f}});
    chart.draw();
    return 0;
}

