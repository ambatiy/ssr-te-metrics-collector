# ssr-te-metrics-collector
This script will collect the SSR metrics of session counters inside ServiceArea during a config push and looks for drops and errors in the packet processing, the output of following commands are recorded into a file and will be uploaded to praxis
1. show stats traffic-eng internal-application node all since 1m | egrep 'Service Area' | egrep 'exceeded|failure|timeout'
2. show stats app-id since 1m
3. show stats service-area received since 1m | egrep 'adaptive|classification-update|dropped-packet|duplicate-reverse|mid-flow-modif'
4. show stats aggregate-session by-node node all | grep session
