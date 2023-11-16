bundle: {
        apiVersion: "v1alpha1"
        name:       "flux-aio"
        instances: {
                "flux": {
                        module: {
                                url:     "oci://ghcr.io/stefanprodan/modules/flux-aio"
                                version: "2.1.2"
                        }
                        namespace: "flux-system"
                        values: {
                                hostNetwork:     true
                                securityProfile: "privileged"
                                controllers: notification: enabled: false
                        }
                }
                "cluster-core-systems": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./core-infrastructure/systems"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "core-system"
                            }
                        }
                }
                "cluster-core-configs": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./core-infrastructure/configs"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "core-system"
                            }
                        }
                }
                "cluster-infra-systems": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./infrastructure/systems"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "infra-system"
                            }
                        }
                }
                "cluster-infra-configs": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./infrastructure/configs"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "infra-system"
                            }
                        }
                }
                "cluster-apps-basic": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./apps/basic"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "apps-system"
                            }
                        }
                }
                "cluster-awx-systems": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./apps/awx/systems"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "awx-system"
                            }
                        }
                }
                "cluster-awx-configs": {
                        module: url: "oci://ghcr.io/stefanprodan/modules/flux-git-sync"
                        namespace: "flux-system"
                        values: {
                            git: {
                                ca:    string @timoni(runtime:string:GIT_CA)
                                token: string @timoni(runtime:string:GIT_TOKEN)
                                url:   "https://vmalmagit.home:3000/flux/HOMEAIO"
                                ref:   "refs/heads/main"
                                path:  "./apps/awx/configs"
                                interval: 1
                                }
                            sync: {
                                prune: true
                                targetNamespace: "awx-system"
                            }
                        }
                }
        }
}