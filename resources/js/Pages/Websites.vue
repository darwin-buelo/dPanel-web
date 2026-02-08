<script setup>
import AuthenticatedLayout from '@/Layouts/AuthenticatedLayout.vue';
import { Head } from '@inertiajs/vue3';
</script>

<template>
    <Head title="Dashboard" />
    <AuthenticatedLayout>
        <v-row>
            <v-col cols="12" class="d-flex justify-space-between align-center">
                <h2 class="text-h5 font-weight-bold">Websites</h2>
                <v-btn color="primary" prepend-icon="mdi-plus">
                    Add Website
                </v-btn>
            </v-col>

            <v-col cols="12">
                <v-card>
                    <v-data-table
                        :headers="[
                            { title: 'Name', key: 'name' },
                            { title: 'URL', key: 'url' },
                            { title: 'Status', key: 'status' },
                            { title: 'Actions', key: 'actions', sortable: false },
                        ]"
                        :items="[
                            { id: 1, name: 'My Personal Blog', url: 'https://blog.example.com', status: 'Active' },
                            { id: 2, name: 'E-commerce Store', url: 'https://shop.example.com', status: 'Active' },
                            { id: 3, name: 'Portfolio', url: 'https://portfolio.me', status: 'Maintenance' },
                        ]"
                        class="elevation-1"
                    >
                        <template v-slot:item.url="{ item }">
                            <a :href="item.url" target="_blank" class="text-blue text-decoration-none">
                                {{ item.url }}
                            </a>
                        </template>
                        <template v-slot:item.actions="{ item }">
                            <v-icon size="small" class="me-2">mdi-pencil</v-icon>
                            <v-icon size="small" color="error">mdi-delete</v-icon>
                        </template>
                    </v-data-table>
                </v-card>
            </v-col>
        </v-row>

    </AuthenticatedLayout>
</template>
