<script setup>
import { ref } from 'vue';
import { router, usePage } from '@inertiajs/vue3';

const drawer = ref(true);
const page = usePage();

const items = [
    { title: 'Dashboard', icon: 'mdi-view-dashboard', url: '/dashboard' },
    { title: 'Pages', icon: 'mdi-file-document', url: '/pages' },
    { title: 'Users', icon: 'mdi-account-group', url: '/users' },
    { title: 'Settings', icon: 'mdi-cog', url: '/settings' },
];
</script>

<template>
    <v-app>
        <v-navigation-drawer v-model="drawer">
            <v-list>
                <v-list-item title="Website Manager" subtitle="Admin Panel"></v-list-item>
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

        <v-app-bar>
            <v-app-bar-nav-icon @click="drawer = !drawer"></v-app-bar-nav-icon>
            <v-app-bar-title>Website Manager</v-app-bar-title>
        </v-app-bar>

        <v-main>
            <v-container fluid>
                <slot />
            </v-container>
        </v-main>
    </v-app>
</template>