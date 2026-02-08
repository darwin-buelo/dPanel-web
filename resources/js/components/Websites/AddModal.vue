<script setup>
import { computed, ref } from 'vue';

const props = defineProps({
    modelValue: Boolean,
});

const emit = defineEmits(['update:modelValue']);

const show = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val),
});

const tab = ref('domain');
</script>

<template>
    <v-dialog v-model="show" max-width="900px">
        <v-card>
            <v-card-title>
                Add New Website
            </v-card-title>

            <div class="d-flex flex-row">
                <v-tabs
                    v-model="tab"
                    direction="vertical"
                    color="primary"
                >
                    <v-tab value="domain">
                        <v-icon start>mdi-web</v-icon>
                        Domain
                    </v-tab>
                    <v-tab value="php">
                        <v-icon start>mdi-language-php</v-icon>
                        PHP
                    </v-tab>
                    <v-tab value="nginx">
                        <v-icon start>mdi-server</v-icon>
                        Nginx
                    </v-tab>
                    <v-tab value="other">
                        <v-icon start>mdi-cog</v-icon>
                        Other
                    </v-tab>
                </v-tabs>

                <v-window v-model="tab" class="flex-grow-1 pa-4">
                    <v-window-item value="domain">
                        <v-form>
                            <v-text-field label="Name" required></v-text-field>
                            <v-text-field label="URL" required></v-text-field>
                            <v-text-field label="Path" required></v-text-field>
                        </v-form>
                    </v-window-item>
                    <v-window-item value="php">
                        <v-select label="PHP Version" :items="['8.3', '8.2', '8.1', '8.0', '7.4']"></v-select>
                    </v-window-item>
                    <v-window-item value="nginx">
                        <v-textarea label="Nginx Configuration"></v-textarea>
                    </v-window-item>
                    <v-window-item value="other">
                        <v-checkbox label="Enable SSL"></v-checkbox>
                    </v-window-item>
                </v-window>
            </div>
            <v-divider></v-divider>
            <v-card-actions>
                <v-spacer></v-spacer>
                <v-btn text @click="show = false">Cancel</v-btn>
                <v-btn color="primary" @click="show = false">Add</v-btn>
            </v-card-actions>
        </v-card>
    </v-dialog>
</template>