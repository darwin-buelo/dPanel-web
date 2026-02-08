<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
import { onMounted, onBeforeUnmount, ref } from 'vue';
import { Terminal } from 'xterm';
import { FitAddon } from 'xterm-addon-fit';
import 'xterm/css/xterm.css';

const terminalContainer = ref(null);
let term = null;
let fitAddon = null;

const handleResize = () => {
    if (fitAddon) {
        fitAddon.fit();
    }
};

onMounted(() => {
    term = new Terminal({
        cursorBlink: true,
        fontSize: 14,
        fontFamily: 'Menlo, Monaco, "Courier New", monospace',
        theme: {
            background: '#1e1e1e',
        }
    });

    fitAddon = new FitAddon();
    term.loadAddon(fitAddon);

    term.open(terminalContainer.value);
    fitAddon.fit();

    term.writeln('Welcome to dPanel Terminal');
    term.write('$ ');

    term.onData(e => {
        if (e === '\r') {
            term.write('\r\n$ ');
        } else if (e === '\u007F') {
            term.write('\b \b');
        } else {
            term.write(e);
        }
    });

    window.addEventListener('resize', handleResize);
});

onBeforeUnmount(() => {
    window.removeEventListener('resize', handleResize);
    if (term) {
        term.dispose();
    }
});
</script>

<template>
    <Head title="Terminal" />
    <AuthenticatedLayout>
        <div ref="terminalContainer" style="height: 75vh; background-color: #1e1e1e; padding: 10px; border-radius: 4px; overflow: hidden;"></div>
    </AuthenticatedLayout>
</template>
