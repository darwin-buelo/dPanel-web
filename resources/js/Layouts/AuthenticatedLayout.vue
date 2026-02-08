<script setup>
import { ref, computed, watch } from 'vue';
import { useTheme } from 'vuetify';
import { router, usePage } from '@inertiajs/vue3';
import ApplicationLogo from '@/Components/ApplicationLogo.vue';
import '@mdi/font/css/materialdesignicons.css';

const drawer = ref(true);
const page = usePage();
const appName = import.meta.env.VITE_APP_NAME || 'Laravel';
const items = [
    { title: 'Dashboard', icon: 'mdi-view-dashboard', url: '/dashboard' },
    { title: 'Websites', icon: 'mdi-web', url: '/websites' },
    { title: 'Terminal', icon: 'mdi-console', url: '/terminal' },
    { title: 'Settings', icon: 'mdi-cog', url: '/settings' },
];

const breadcrumbs = computed(() => {
    const url = page.url.split('?')[0];
    if (url === '/dashboard') {
        return [{ title: 'Dashboard', disabled: true, href: '/dashboard' }];
    }

    const crumbs = [
        { title: 'Dashboard', disabled: false, href: '/dashboard' }
    ];

    const segments = url.split('/').filter(p => p);
    let currentPath = '';

    segments.forEach((segment, index) => {
        currentPath += `/${segment}`;
        if (segment === 'dashboard') return;

        const isLast = index === segments.length - 1;
        const menuItem = items.find(i => i.url === currentPath);

        crumbs.push({
            title: menuItem ? menuItem.title : segment.replace(/-/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
            disabled: isLast,
            href: currentPath
        });
    });

    return crumbs;
});

const theme = useTheme();

watch(() => theme.global.name.value, (val) => {
    localStorage.setItem('theme', val);
    const isDark = theme.global.current.value.dark;
    if (isDark) {
        document.documentElement.classList.add('dark');
    } else {
        document.documentElement.classList.remove('dark');
    }
}, { immediate: true });

const themes = [
    { title: 'Light', value: 'lightBlue', icon: 'mdi-weather-sunny' },
    { title: 'Dark', value: 'darkBlue', icon: 'mdi-weather-night' }
];
function setTheme(key) {
    theme.global.name.value = key;
}
const themeIcon = computed(() => themes.find(t => t.value === theme.global.name.value)?.icon || 'mdi-weather-sunny');
</script>

<template>
    <v-app>
        <v-navigation-drawer v-model="drawer">
            <v-list density="compact" nav>
                <v-list-item :title="appName" subtitle="Admin Panel">
                    <template v-slot:prepend>
                        <ApplicationLogo style="width: 40px; margin-right: 10px;"/>
                    </template>
                </v-list-item>
                <v-divider></v-divider>

                <v-list-item
                    v-for="item in items"
                    :key="item.title"
                    :prepend-icon="item.icon"
                    :title="item.title"
                    :active="page.url.startsWith(item.url)"
                    @click="router.get(item.url)"
                    link
                ></v-list-item>
            </v-list>
        </v-navigation-drawer>

        <v-app-bar density="compact">
            <v-spacer></v-spacer>
            <v-menu>
                <template v-slot:activator="{ props }">
                    <v-btn icon v-bind="props">
                        <v-icon>{{ themeIcon }}</v-icon>
                    </v-btn>
                </template>
                <v-list>
                    <v-list-item v-for="t in themes" :key="t.value" :title="t.title" :prepend-icon="t.icon" @click="setTheme(t.value)" link></v-list-item>
                </v-list>
            </v-menu>
            <v-menu>
                <template v-slot:activator="{ props }">
                    <v-btn v-bind="props" variant="text">
                        {{ $page.props.auth.user.name }}
                        <v-icon icon="mdi-chevron-down" end></v-icon>
                    </v-btn>
                </template>
                <v-list>
                    <v-list-item @click="router.get(route('profile.edit'))" title="Profile"></v-list-item>
                    <v-list-item @click="router.post(route('logout'))" title="Log Out"></v-list-item>
                </v-list>
            </v-menu>
        </v-app-bar>

        <v-main>
            <v-container fluid>
                <v-breadcrumbs :items="breadcrumbs" class="mb-4">
                    <template v-slot:item="{ item }">
                        <v-breadcrumbs-item
                            :disabled="item.disabled"
                            :href="item.href"
                            @click.prevent="!item.disabled && router.get(item.href)"
                        >
                            {{ item.title }}
                        </v-breadcrumbs-item>
                    </template>
                </v-breadcrumbs>
                <slot />
            </v-container>
        </v-main>
    </v-app>
</template>
