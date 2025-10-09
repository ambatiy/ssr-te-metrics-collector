# ssr-te-metrics-collector
This script will collect the SSR metrics of session counters inside ServiceArea during a config push and looks for drops and errors in the packet processing\n
  The output of following commands are recorded into a file and will be uploaded to praxis\n
    1. show stats traffic-eng internal-application node all since 1m | egrep 'Service Area' | egrep 'exceeded|failure|timeout'\n
    2. show stats app-id since 1m\n
    3. show stats service-area received since 1m | egrep 'adaptive|classification-update|dropped-packet|duplicate-reverse|mid-flow-modif'\n
    4. show stats aggregate-session by-node node all | grep session\n
